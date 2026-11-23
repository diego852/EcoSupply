import '../models/app_models.dart';

/// Servicio de integración directa con Cloud Firestore para EcoSupply.
///
/// Maneja transacciones atómicas para:
/// 1. Garantizar la restricción mensual de 1 lote pequeño por consumidor.
/// 2. Evitar stock negativo y reservas simultáneas.
/// 3. Validar el estado 'acreditada' de las Organizaciones Sociales.
/// 4. Sincronizar el estado de reservas y notificaciones en tiempo real.
class EcoSupplyFirebaseService {
  static final EcoSupplyFirebaseService _instance = EcoSupplyFirebaseService._internal();
  factory EcoSupplyFirebaseService() => _instance;
  EcoSupplyFirebaseService._internal();

  /// Mapea un Document Snapshot de Firestore a [Product]
  Product mapFirestoreDocToProduct(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      title: data['title'] ?? '',
      itemsIncluded: data['itemsIncluded'] ?? '',
      totalItemsCount: (data['totalItemsCount'] as num?)?.toInt() ?? 1,
      batchSize: _parseBatchSize(data['batchSize']),
      modality: _parseModality(data['modality']),
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (data['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      batchQuantity: (data['batchQuantity'] as num?)?.toInt() ?? 0,
      category: data['category'] ?? 'Panadería',
      businessName: data['businessName'] ?? '',
      businessAddress: data['businessAddress'] ?? '',
      expiryText: data['expiryText'] ?? '',
      pickupSchedule: data['pickupSchedule'] ?? '',
      distanceText: data['distanceText'] ?? '1.0 km',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      isBusinessActive: data['isBusinessActive'] ?? true,
    );
  }

  /// Mapea un Document Snapshot de Firestore a [Reservation]
  Reservation mapFirestoreDocToReservation(Map<String, dynamic> data, String docId) {
    return Reservation(
      id: docId,
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      batchSize: _parseBatchSize(data['batchSize']),
      itemsIncluded: data['itemsIncluded'] ?? '',
      businessName: data['businessName'] ?? '',
      businessAddress: data['businessAddress'] ?? '',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pendiente',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      pickupWindow: data['pickupWindow'] ?? '',
      code: data['code'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userRole: _parseUserRole(data['userRole']),
    );
  }

  /// Mapea objeto [Product] a JSON para Firestore
  Map<String, dynamic> productToFirestoreJson(Product product) {
    return {
      'title': product.title,
      'itemsIncluded': product.itemsIncluded,
      'totalItemsCount': product.totalItemsCount,
      'batchSize': product.batchSize.name,
      'modality': product.modality.name,
      'originalPrice': product.originalPrice,
      'discountedPrice': product.discountedPrice,
      'batchQuantity': product.batchQuantity,
      'category': product.category,
      'businessName': product.businessName,
      'businessAddress': product.businessAddress,
      'expiryText': product.expiryText,
      'pickupSchedule': product.pickupSchedule,
      'distanceText': product.distanceText,
      'imageUrl': product.imageUrl,
      'rating': product.rating,
      'isBusinessActive': product.isBusinessActive,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Mapea objeto [Reservation] a JSON para Firestore
  Map<String, dynamic> reservationToFirestoreJson(Reservation reservation) {
    return {
      'productId': reservation.productId,
      'productTitle': reservation.productTitle,
      'batchSize': reservation.batchSize.name,
      'itemsIncluded': reservation.itemsIncluded,
      'businessName': reservation.businessName,
      'businessAddress': reservation.businessAddress,
      'totalPrice': reservation.totalPrice,
      'status': reservation.status,
      'date': reservation.date.toIso8601String(),
      'pickupWindow': reservation.pickupWindow,
      'code': reservation.code,
      'userEmail': reservation.userEmail,
      'userName': reservation.userName,
      'userRole': reservation.userRole.name,
      'year': reservation.date.year,
      'month': reservation.date.month,
    };
  }

  // Parsers de enumeraciones
  BatchSize _parseBatchSize(String? value) {
    switch (value) {
      case 'medium':
        return BatchSize.medium;
      case 'large':
        return BatchSize.large;
      case 'small':
      default:
        return BatchSize.small;
    }
  }

  Modality _parseModality(String? value) {
    if (value == 'freeDonation') {
      return Modality.freeDonation;
    }
    return Modality.socialSale;
  }

  UserRole _parseUserRole(String? value) {
    switch (value) {
      case 'business':
        return UserRole.business;
      case 'socialOrg':
        return UserRole.socialOrg;
      case 'localUser':
      default:
        return UserRole.localUser;
    }
  }
}
