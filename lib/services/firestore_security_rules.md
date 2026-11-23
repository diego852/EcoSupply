# Especificación de Seguridad e Integración con Firebase / Cloud Firestore para EcoSupply

Esta especificación detalla el esquema de base de datos, la función Cloud Function transaccional y las Reglas de Seguridad para garantizar la restricción mensual de lotes y evitar condiciones de carrera (reservas simultáneas).

---

## 1. Esquema de Firestore

### Colección `users` (`/users/{userId}`)
```json
{
  "uid": "USER123",
  "name": "Carlos Mendoza",
  "email": "carlos.mendoza@email.com",
  "role": "localUser",
  "isAccredited": false
}
```

### Colección `publications` (`/publications/{publicationId}`)
```json
{
  "publicationId": "PUB001",
  "title": "Lote Pequeño: Panes Artesanales del Día",
  "itemsIncluded": "4 baguettes, 3 ciabattas, 2 croissants",
  "totalItemsCount": 9,
  "batchSize": "small",
  "modality": "socialSale",
  "originalPrice": 15.00,
  "discountedPrice": 6.00,
  "batchQuantity": 3,
  "businessId": "BIZ_001",
  "businessName": "Panadería Don Lucho",
  "businessAddress": "Av. Larco 456, Miraflores, Lima",
  "pickupSchedule": "5:00 PM - 7:00 PM",
  "createdAt": "TIMESTAMP"
}
```

### Colección `reservations` (`/reservations/{reservationId}`)
```json
{
  "reservationId": "RES_101",
  "publicationId": "PUB001",
  "userUid": "USER123",
  "userEmail": "carlos.mendoza@email.com",
  "userRole": "localUser",
  "batchSize": "small",
  "modality": "socialSale",
  "status": "Lista para recoger",
  "totalPrice": 6.00,
  "pickupCode": "ECO-8492",
  "year": 2025,
  "month": 2,
  "createdAt": "TIMESTAMP"
}
```

---

## 2. Cloud Function para Confirmar Reserva (Atómica e Inviolable)

Para evitar reservas simultáneas y eludir la restricción mensual, la reserva debe ejecutarse mediante un **Cloud Firestore Transaction** en la Cloud Function `confirmBatchReservation`:

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.confirmBatchReservation = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Debes iniciar sesión.");
  }

  const { publicationId, pickupWindow } = data;
  const userUid = context.auth.uid;

  return await db.runTransaction(async (transaction) => {
    // 1. Obtener Usuario
    const userRef = db.collection("users").doc(userUid);
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Usuario no encontrado.");
    }
    const userData = userDoc.data();
    const userRole = userData.role;

    // 2. Obtener Publicación del Lote
    const pubRef = db.collection("publications").doc(publicationId);
    const pubDoc = await transaction.get(pubRef);
    if (!pubDoc.exists) {
      throw new functions.https.HttpsError("not-found", "La publicación no existe.");
    }
    const pubData = pubDoc.data();

    // 3. Validar Stock
    if (pubData.batchQuantity <= 0) {
      throw new functions.https.HttpsError("failed-precondition", "Agotado. No quedan lotes disponibles.");
    }

    // 4. Validar Reglas de Rol
    if (pubData.modality === "freeDonation" && userRole === "localUser") {
      throw new functions.https.HttpsError("permission-denied", "Las donaciones gratuitas son exclusivas para ONGs.");
    }

    if ((pubData.batchSize === "medium" || pubData.batchSize === "large") && userRole === "localUser") {
      throw new functions.https.HttpsError("permission-denied", "Los lotes medianos y grandes son exclusivos para ONGs.");
    }

    // 5. Validar Restricción Mensual para Consumidores Locales
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1; // 1-12

    if (userRole === "localUser" && pubData.batchSize === "small") {
      const activeResQuery = db.collection("reservations")
        .where("userUid", "==", userUid)
        .where("batchSize", "==", "small")
        .where("year", "==", currentYear)
        .where("month", "==", currentMonth)
        .where("status", "in", ["Pendiente", "Lista para recoger", "Completada"]);

      const existingResSnap = await transaction.get(activeResQuery);
      if (!existingResSnap.empty) {
        throw new functions.https.HttpsError(
          "already-exists",
          "Ya has utilizado tu cupo mensual de 1 lote pequeño para este mes."
        );
      }
    }

    // 6. Generar Código QR Único y Crear Reserva
    const code = "ECO-" + Math.floor(1000 + Math.random() * 9000);
    const resRef = db.collection("reservations").doc();

    transaction.set(resRef, {
      reservationId: resRef.id,
      publicationId: publicationId,
      publicationTitle: pubData.title,
      itemsIncluded: pubData.itemsIncluded,
      userUid: userUid,
      userEmail: userData.email,
      userName: userData.name,
      userRole: userRole,
      batchSize: pubData.batchSize,
      modality: pubData.modality,
      totalPrice: pubData.discountedPrice,
      businessName: pubData.businessName,
      businessAddress: pubData.businessAddress,
      status: "Lista para recoger",
      pickupWindow: pickupWindow,
      pickupCode: code,
      year: currentYear,
      month: currentMonth,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // 7. Descontar exactamente 1 lote del stock
    transaction.update(pubRef, {
      batchQuantity: pubData.batchQuantity - 1
    });

    return { success: true, pickupCode: code, reservationId: resRef.id };
  });
});
```

---

## 3. Reglas de Seguridad en Cloud Firestore (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function isONG() {
      return isAuthenticated() && getUserData().role == 'socialOrg';
    }

    // Reglas para la colección 'users'
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }

    // Reglas para la colección 'publications'
    match /publications/{pubId} {
      allow read: if isAuthenticated();
      // Solo establecimientos pueden publicar
      allow create, update, delete: if isAuthenticated() && getUserData().role == 'business';
    }

    // Reglas para la colección 'reservations'
    match /reservations/{resId} {
      allow read: if isAuthenticated() && (
        resource.data.userUid == request.auth.uid ||
        getUserData().role == 'business' ||
        getUserData().role == 'socialOrg'
      );
      
      // La creación directa se deniega para forzar el uso de la Cloud Function transaccional
      allow create: if false; 

      // Solo el establecimiento o la persona que reservó puede actualizar estado (ej. Cancelar)
      allow update: if isAuthenticated() && (
        resource.data.userUid == request.auth.uid ||
        getUserData().role == 'business'
      );
    }
  }
}
```
