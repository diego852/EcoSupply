import 'package:flutter/material.dart';

import '../models/app_models.dart';

class QrValidationResult {
  final bool isValid;
  final String message;
  final Reservation? reservation;

  QrValidationResult({
    required this.isValid,
    required this.message,
    this.reservation,
  });
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
    } else {
      final scope = context.getInheritedWidgetOfExactType<AppStateScope>();
      return scope!.notifier!;
    }
  }
}

class Provider {
  static AppState of<T>(BuildContext context, {bool listen = true}) {
    return AppStateScope.of(context, listen: listen);
  }
}

class AppState extends ChangeNotifier {
  UserRole _currentRole = UserRole.localUser;
  OngAccreditationStatus _ongStatus = OngAccreditationStatus.accredited;
  String _userName = 'Carlos Mendoza';
  String _userEmail = 'carlos.mendoza@email.com';
  String _userDni = '71234567';
  String _userLocation = 'Piura';
  AccountStatus _userAccountStatus = AccountStatus.activa; // Por defecto activo para demo
  DateTime? _userApprovalDate = DateTime.now();
  DateTime? _userExpirationDate = DateTime.now().add(const Duration(days: 365));

  final String _businessName = 'Panadería Don Lucho';
  final String _orgName = 'Comedor Popular Santa Rosa';

  UserRole get currentRole => _currentRole;
  OngAccreditationStatus get ongStatus => _ongStatus;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userDni => _userDni;
  String get userLocation => _userLocation;
  String get businessName => _businessName;
  String get orgName => _orgName;
  AccountStatus get userAccountStatus => _userAccountStatus;
  DateTime? get userApprovalDate => _userApprovalDate;
  DateTime? get userExpirationDate => _userExpirationDate;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void setOngStatus(OngAccreditationStatus status) {
    _ongStatus = status;
    notifyListeners();
  }

  void setAccountStatus(AccountStatus status) {
    _userAccountStatus = status;
    notifyListeners();
  }

  void setUserInfo({
    required String name,
    required String email,
    String? dni,
    String? location,
    UserRole? role,
    AccountStatus? accountStatus,
  }) {
    _userName = name;
    _userEmail = email;
    if (dni != null) _userDni = dni;
    if (location != null && location.isNotEmpty) _userLocation = location;
    if (role != null) _currentRole = role;
    if (accountStatus != null) _userAccountStatus = accountStatus;
    notifyListeners();
  }

  // Lista de cuentas de usuario registradas
  final List<UserProfile> _registeredUserProfiles = [
    UserProfile(
      uid: 'u_demo_1',
      fullName: 'Marco R. Silva',
      email: 'marco.r@email.com',
      phone: '987654321',
      dni: '71829304',
      role: UserRole.localUser,
      department: 'Piura',
      province: 'Piura',
      address: 'Av. Grau 410',
      district: 'Piura',
      status: AccountStatus.pendiente,
      sisfohClassification: SisfohClassification.pobreExtremo,
      attachedDocuments: [
        DocumentAttachment(
          id: 'doc_1',
          fileName: 'Constancia_CSE_SISFOH_Marco.pdf',
          fileType: 'application/pdf',
          fileSizeMb: 1.4,
          uploadDate: DateTime.now(),
        ),
      ],
    ),
    UserProfile(
      uid: 'u_demo_2',
      fullName: 'Comedor Popular Santa Rosa',
      email: 'santa.rosa@ong.org',
      phone: '976543210',
      role: UserRole.socialOrg,
      orgType: 'Comedor Popular',
      department: 'Piura',
      province: 'Piura',
      address: 'Calle Real 120',
      district: 'Castilla',
      status: AccountStatus.pendiente,
      attachedDocuments: [
        DocumentAttachment(
          id: 'doc_2',
          fileName: 'Resolucion_Municipal_Comedor.pdf',
          fileType: 'application/pdf',
          fileSizeMb: 2.1,
          uploadDate: DateTime.now(),
        ),
      ],
    ),
    UserProfile(
      uid: 'u_demo_3',
      fullName: 'Panadería & Pastelería Don Lucho',
      email: 'donlucho@panaderia.com',
      phone: '987123456',
      ruc: '20123456789',
      role: UserRole.business,
      businessType: 'Panadería',
      department: 'Piura',
      province: 'Piura',
      district: 'Piura',
      address: 'Av. Grau 450, Piura',
      latitude: -5.1945,
      longitude: -80.6328,
      status: AccountStatus.pendiente,
      attachedDocuments: [
        DocumentAttachment(
          id: 'doc_3',
          fileName: 'Licencia_Funcionamiento_Municipal.pdf',
          fileType: 'application/pdf',
          fileSizeMb: 1.9,
          uploadDate: DateTime.now(),
        ),
        DocumentAttachment(
          id: 'doc_4',
          fileName: 'Ficha_RUC_SUNAT_Activo_Habido.pdf',
          fileType: 'application/pdf',
          fileSizeMb: 1.2,
          uploadDate: DateTime.now(),
        ),
        DocumentAttachment(
          id: 'doc_5',
          fileName: 'Foto_Fachada_Local_DonLucho.jpg',
          fileType: 'image/jpeg',
          fileSizeMb: 2.8,
          uploadDate: DateTime.now(),
        ),
      ],
    ),
  ];

  List<UserProfile> get registeredUserProfiles => List.unmodifiable(_registeredUserProfiles);

  bool isDniAlreadyRegistered(String dni) {
    if (dni.trim().isEmpty) return false;
    return _registeredUserProfiles.any((p) => p.dni == dni.trim());
  }

  bool isRucAlreadyRegistered(String ruc) {
    if (ruc.trim().isEmpty) return false;
    return _registeredUserProfiles.any((p) => p.ruc == ruc.trim());
  }

  bool isEmailAlreadyRegistered(String email) {
    if (email.trim().isEmpty) return false;
    return _registeredUserProfiles.any((p) => p.email.toLowerCase() == email.trim().toLowerCase());
  }

  void registerUserAccount(UserProfile profile) {
    _registeredUserProfiles.insert(0, profile);
    _userName = profile.fullName;
    _userEmail = profile.email;
    _userDni = profile.dni;
    _userLocation = profile.district;
    _currentRole = profile.role;
    _userAccountStatus = profile.status;
    notifyListeners();
  }

  void approveUserAccount(String uid) {
    final idx = _registeredUserProfiles.indexWhere((p) => p.uid == uid);
    if (idx != -1) {
      final profile = _registeredUserProfiles[idx];
      profile.status = AccountStatus.activa;
      profile.approvalDate = DateTime.now();
      profile.expirationDate = DateTime.now().add(const Duration(days: 365));

      if (profile.email.toLowerCase() == _userEmail.toLowerCase()) {
        _userAccountStatus = AccountStatus.activa;
        _userApprovalDate = profile.approvalDate;
        _userExpirationDate = profile.expirationDate;
      }

      addNotification(
        '¡Cuenta Aprobada!',
        'Tu registro en EcoSupply ha sido APROBADO por el administrador. Ya puedes hacer uso completo de la plataforma.',
        profile.email,
      );

      notifyListeners();
    }
  }

  void rejectUserAccount(String uid, String reason) {
    final idx = _registeredUserProfiles.indexWhere((p) => p.uid == uid);
    if (idx != -1) {
      final profile = _registeredUserProfiles[idx];
      profile.status = AccountStatus.rechazada;
      profile.rejectionReason = reason;

      if (profile.email.toLowerCase() == _userEmail.toLowerCase()) {
        _userAccountStatus = AccountStatus.rechazada;
      }

      addNotification(
        'Solicitud de Registro Rechazada',
        'Tu registro en EcoSupply fue rechazado. Motivo: $reason',
        profile.email,
      );

      notifyListeners();
    }
  }

  // Notificaciones
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  void addNotification(String title, String body, String email) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        userEmail: email,
      ),
    );
    notifyListeners();
  }

  void markNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // Publicaciones por Lote Completo en Piura
  final List<Product> _products = [
    Product(
      id: 'prod_1',
      title: 'Lote Pequeño: Panes Artesanales del Día',
      itemsIncluded: '4 baguettes de masa madre, 3 ciabattas, 2 croissants',
      totalItemsCount: 9,
      batchSize: BatchSize.small,
      modality: Modality.socialSale,
      originalPrice: 15.00,
      discountedPrice: 6.00,
      batchQuantity: 3,
      category: 'Panadería',
      businessName: 'Panadería Don Lucho',
      businessAddress: 'Av. Grau 450, Piura',
      distanceText: '0.8 km',
      expiryText: 'Hoy hasta las 7:00 pm',
      pickupSchedule: '5:00 PM - 7:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      rating: 4.9,
    ),
    Product(
      id: 'prod_2',
      title: 'Lote Pequeño: Torta & Repostería Fina',
      itemsIncluded: '2 porciones de torta de maracuyá, 2 tartaletas de fresa',
      totalItemsCount: 4,
      batchSize: BatchSize.small,
      modality: Modality.socialSale,
      originalPrice: 18.00,
      discountedPrice: 7.00,
      batchQuantity: 2,
      category: 'Café',
      businessName: 'Dulces de Piura',
      businessAddress: 'Calle Libertad 320, Piura',
      distanceText: '1.1 km',
      expiryText: 'Hoy hasta las 8:00 pm',
      pickupSchedule: '6:00 PM - 8:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?w=400',
      rating: 4.8,
    ),
    Product(
      id: 'prod_3',
      title: 'Lote Grande: Donación 12 Menús Criollos',
      itemsIncluded: '12 raciones completas de seco de res con frijoles y entradas',
      totalItemsCount: 12,
      batchSize: BatchSize.large,
      modality: Modality.freeDonation,
      originalPrice: 140.00,
      discountedPrice: 0.00,
      batchQuantity: 1,
      category: 'Menús',
      businessName: 'Café Tallán',
      businessAddress: 'Av. Bolognesi 180, Piura',
      distanceText: '1.2 km',
      expiryText: 'Hoy hasta las 6:00 pm',
      pickupSchedule: '4:00 PM - 6:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      rating: 5.0,
    ),
    Product(
      id: 'prod_4',
      title: 'Lote Pequeño: Frutas Variadas de Estación',
      itemsIncluded: '2 kg de mandarinas, 1.5 kg de plátanos de seda',
      totalItemsCount: 10,
      batchSize: BatchSize.small,
      modality: Modality.socialSale,
      originalPrice: 14.00,
      discountedPrice: 5.50,
      batchQuantity: 4,
      category: 'Frutas',
      businessName: 'Mercado Modelos',
      businessAddress: 'Av. Sullana 510, Piura',
      distanceText: '2.3 km',
      expiryText: 'Hoy hasta las 5:00 pm',
      pickupSchedule: '3:00 PM - 5:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
      rating: 4.7,
    ),
    Product(
      id: 'prod_5',
      title: 'Lote Mediano: Donación 40 Panes Integrales',
      itemsIncluded: '40 panes integrales empacados para comedor o banco de alimentos',
      totalItemsCount: 40,
      batchSize: BatchSize.medium,
      modality: Modality.freeDonation,
      originalPrice: 50.00,
      discountedPrice: 0.00,
      batchQuantity: 2,
      category: 'Panadería',
      businessName: 'Panadería San Miguel',
      businessAddress: 'Av. Junín 210, Castilla, Piura',
      distanceText: '1.6 km',
      expiryText: 'Hoy hasta las 7:00 pm',
      pickupSchedule: '5:00 PM - 7:00 PM',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      rating: 4.9,
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  // Reservas Iniciales
  final List<Reservation> _reservations = [
    Reservation(
      id: 'res_demo_1',
      productId: 'prod_1',
      productTitle: 'Pack de panes x2',
      batchSize: BatchSize.small,
      itemsIncluded: '4 baguettes de masa madre, 3 ciabattas, 2 croissants',
      businessName: 'Panadería Don Lucho',
      businessAddress: 'Av. Grau 450, Piura',
      totalPrice: 12.00,
      status: 'pendiente',
      date: DateTime.now(),
      pickupWindow: 'Hoy 5:30 pm',
      code: 'ECO-5301',
      userEmail: 'marco.r@email.com',
      userName: 'Marco R.',
      userDni: '71829304',
      userRole: UserRole.localUser,
      userLocation: 'Piura',
      distanceText: '0.8 km',
    ),
    Reservation(
      id: 'res_demo_2',
      productId: 'prod_3',
      productTitle: 'Menú x10',
      batchSize: BatchSize.large,
      itemsIncluded: '10 raciones completas de menú criollo',
      businessName: 'Panadería Don Lucho',
      businessAddress: 'Av. Grau 450, Piura',
      totalPrice: 0.00,
      status: 'pendiente',
      date: DateTime.now(),
      pickupWindow: 'Hoy 4:15 pm',
      code: 'ECO-4152',
      userEmail: 'santa.rosa@ong.org',
      userName: 'Comedor Santa Rosa',
      userRole: UserRole.socialOrg,
      userLocation: 'Castilla, Piura',
      distanceText: '2.3 km',
    ),
  ];

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  Reservation? getConsumerMonthlyConfirmedReservation(String email) {
    final now = DateTime.now();
    for (var res in _reservations) {
      if (res.userEmail.toLowerCase() == email.toLowerCase() &&
          res.batchSize == BatchSize.small &&
          (res.status == 'confirmada' || res.status == 'Lista para recoger' || res.status == 'retirada' || res.status == 'Completada') &&
          res.date.year == now.year &&
          res.date.month == now.month) {
        return res;
      }
    }
    return null;
  }

  bool hasUsedMonthlyQuota(String email) {
    return getConsumerMonthlyConfirmedReservation(email) != null;
  }

  DateTime getNextQuotaAvailableDate() {
    final now = DateTime.now();
    if (now.month == 12) {
      return DateTime(now.year + 1, 1, 1);
    } else {
      return DateTime(now.year, now.month + 1, 1);
    }
  }

  String calculateDistanceText(String userLoc, String businessLoc) {
    final u = userLoc.toLowerCase();
    final b = businessLoc.toLowerCase();

    if (u.contains('piura') && b.contains('piura')) {
      return '0.8 km';
    } else if (u.contains('castilla') || b.contains('castilla')) {
      return '2.3 km';
    } else if (u.contains('octubre') || b.contains('octubre')) {
      return '1.5 km';
    } else if (u.contains('catacaos') || b.contains('catacaos')) {
      return '4.2 km';
    }
    return '1.8 km';
  }

  String? validateReservation({
    required Product product,
    required UserRole userRole,
    required String userEmail,
  }) {
    if (userRole == UserRole.localUser && _userAccountStatus != AccountStatus.activa) {
      if (_userAccountStatus == AccountStatus.pendiente) {
        return 'Tu cuenta se encuentra PENDIENTE DE VERIFICACIÓN por el administrador. Podrás reservar una vez que tus documentos SISFOH sean aprobados.';
      } else if (_userAccountStatus == AccountStatus.vencida) {
        return 'Tu verificación socioeconómica de 12 meses ha VENCIDO. Debes volver a adjuntar tu constancia CSE en tu Perfil.';
      } else {
        return 'Tu cuenta no se encuentra activa en este momento.';
      }
    }

    if (userRole == UserRole.business && _userAccountStatus != AccountStatus.activa) {
      return 'Tu establecimiento se encuentra PENDIENTE DE VERIFICACIÓN por el administrador. Podrás operar una vez que se apruebe la verificación de tu local.';
    }

    if (!product.isBusinessActive) {
      return 'El establecimiento se encuentra inactivo en este momento.';
    }

    if (product.batchQuantity <= 0) {
      return 'Publicación agotada. No quedan lotes disponibles.';
    }

    if (product.modality == Modality.freeDonation) {
      if (userRole == UserRole.localUser) {
        return 'Las donaciones gratuitas están reservadas exclusivamente para organizaciones sociales acreditadas (ONGs).';
      }
      if (userRole == UserRole.socialOrg && !_ongStatus.canRequestDonations) {
        return 'Tu organización social tiene estado "${_ongStatus.displayName}". Solo las organizaciones con estado "Acreditada" pueden solicitar donaciones gratuitas.';
      }
    }

    if (product.batchSize == BatchSize.medium || product.batchSize == BatchSize.large) {
      if (userRole == UserRole.localUser) {
        return 'Los lotes medianos y grandes están destinados exclusivamente a organizaciones sociales acreditadas.';
      }
      if (userRole == UserRole.socialOrg && !_ongStatus.canRequestDonations) {
        return 'Tu organización social tiene estado "${_ongStatus.displayName}". Requiere estado "Acreditada" para reservar lotes medianos o grandes.';
      }
    }

    if (userRole == UserRole.localUser && product.batchSize == BatchSize.small) {
      if (hasUsedMonthlyQuota(userEmail)) {
        final nextDate = getNextQuotaAvailableDate();
        final formattedDate = '${nextDate.day}/${nextDate.month}/${nextDate.year}';
        return 'Ya tienes una reserva confirmada de 1 lote pequeño para este mes. Podrás solicitar otro a partir del $formattedDate.';
      }
    }

    return null;
  }

  void addReservation(Reservation reservation) {
    _reservations.insert(0, reservation);
    notifyListeners();
  }

  bool acceptReservation(String reservationId) {
    final idx = _reservations.indexWhere((r) => r.id == reservationId);
    if (idx != -1) {
      final res = _reservations[idx];

      final prodIdx = _products.indexWhere((p) => p.id == res.productId);
      if (prodIdx == -1 || _products[prodIdx].batchQuantity <= 0) {
        return false;
      }

      if (res.userRole == UserRole.localUser && res.batchSize == BatchSize.small) {
        if (hasUsedMonthlyQuota(res.userEmail)) {
          res.status = 'rechazada';
          addNotification(
            'Solicitud Rechazada',
            'Tu solicitud para "${res.productTitle}" fue rechazada porque ya utilizaste tu cupo mensual.',
            res.userEmail,
          );
          notifyListeners();
          return false;
        }
      }

      _products[prodIdx].batchQuantity -= 1;
      res.status = 'confirmada';

      addNotification(
        '¡Solicitud Aceptada!',
        'Tu reserva para "${res.productTitle}" fue ACEPTADA por ${res.businessName}. Código QR de recojo disponible en Mis Reservas.',
        res.userEmail,
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  void rejectReservation(String reservationId) {
    final idx = _reservations.indexWhere((r) => r.id == reservationId);
    if (idx != -1) {
      final res = _reservations[idx];
      res.status = 'rechazada';

      addNotification(
        'Solicitud Rechazada',
        'Tu solicitud para "${res.productTitle}" fue rechazada por el comercio.',
        res.userEmail,
      );

      notifyListeners();
    }
  }

  void cancelReservation(String reservationId) {
    final idx = _reservations.indexWhere((r) => r.id == reservationId);
    if (idx != -1) {
      final res = _reservations[idx];
      final previousStatus = res.status;
      res.status = 'cancelada';

      if (previousStatus == 'confirmada' || previousStatus == 'Lista para recoger') {
        final prodIdx = _products.indexWhere((p) => p.id == res.productId);
        if (prodIdx != -1) {
          _products[prodIdx].batchQuantity += 1;
        }
      }

      notifyListeners();
    }
  }

  void updateReservationStatus(String reservationId, String newStatus) {
    final idx = _reservations.indexWhere((r) => r.id == reservationId);
    if (idx != -1) {
      _reservations[idx].status = newStatus;
      notifyListeners();
    }
  }

  // Validación y Canje de Código QR en Tienda con DNI del Consumidor
  QrValidationResult validateAndRedeemBatchQr({
    required String rawPayload,
    required String scanningBusinessName,
    String? providedDni,
  }) {
    final parts = rawPayload.split('|');
    String resId = '';
    String code = '';

    if (parts.length >= 3 && parts[0] == 'ECOSUPPLY') {
      resId = parts[1];
      code = parts[2];
    } else {
      code = rawPayload.trim().toUpperCase();
    }

    final idx = _reservations.indexWhere((r) => (resId.isNotEmpty && r.id == resId) || r.code == code);
    if (idx == -1) {
      return QrValidationResult(
        isValid: false,
        message: 'No se encontró ninguna reserva para el código "$code" en la base de datos.',
      );
    }

    final res = _reservations[idx];

    if (res.businessName.trim().toLowerCase() != scanningBusinessName.trim().toLowerCase()) {
      return QrValidationResult(
        isValid: false,
        message: 'Acceso denegado: Esta reserva pertenece a "${res.businessName}". No puedes entregarla desde "$scanningBusinessName".',
        reservation: res,
      );
    }

    if (res.userRole == UserRole.localUser && providedDni != null && providedDni.trim().isNotEmpty) {
      if (res.userDni.isNotEmpty && res.userDni.trim() != providedDni.trim()) {
        return QrValidationResult(
          isValid: false,
          message: 'DNI No Coincide: El DNI ingresado ($providedDni) no coincide con el DNI registrado en la reserva (${res.userDni}).',
          reservation: res,
        );
      }
    }

    if (res.status == 'pendiente') {
      return QrValidationResult(
        isValid: false,
        message: 'Solicitud pendiente: La reserva aún no ha sido ACEPTADA por el comercio.',
        reservation: res,
      );
    }

    if (res.status == 'rechazada') {
      return QrValidationResult(
        isValid: false,
        message: 'Reserva rechazada: La solicitud fue rechazada previamente.',
        reservation: res,
      );
    }

    if (res.status == 'cancelada') {
      return QrValidationResult(
        isValid: false,
        message: 'Reserva cancelada: Esta solicitud fue cancelada y no puede entregarse.',
        reservation: res,
      );
    }

    if (res.status == 'vencida') {
      return QrValidationResult(
        isValid: false,
        message: 'Reserva vencida: El horario límite para recoger el lote ha expirado.',
        reservation: res,
      );
    }

    if (res.status == 'retirada' || res.status == 'Completada') {
      final dateFormatted = res.redeemedAt != null
          ? '${res.redeemedAt!.day}/${res.redeemedAt!.month}/${res.redeemedAt!.year} a las ${res.redeemedAt!.hour}:${res.redeemedAt!.minute.toString().padLeft(2, '0')}'
          : 'anteriormente';
      return QrValidationResult(
        isValid: false,
        message: '¡Atención! Este QR YA FUE UTILIZADO y el lote fue entregado $dateFormatted. No se permite un segundo retiro.',
        reservation: res,
      );
    }

    res.status = 'retirada';
    res.redeemedAt = DateTime.now();
    res.redeemedByBusiness = scanningBusinessName;

    addNotification(
      '¡Lote Completo Entregado!',
      'Has completado el retiro de tu ${res.batchSize.displayName} ("${res.productTitle}") en ${res.businessName}. ¡Gracias por ayudar a reducir el desperdicio!',
      res.userEmail,
    );

    notifyListeners();

    return QrValidationResult(
      isValid: true,
      message: '¡Código QR Válido! Se verificó el DNI (${res.userDni}) y se registró la entrega de 1 ${res.batchSize.displayName}.',
      reservation: res,
    );
  }

  // Solicitudes Sociales
  final List<SocialRequest> _socialRequests = [
    SocialRequest(
      id: 'req_1',
      orgName: 'Comedor Popular "Santa Rosa"',
      foodType: 'Verduras, arroz y abarrotes básicos para 120 raciones',
      peopleServed: 120,
      urgency: 'Alta',
      status: 'Pendiente',
      requestDate: DateTime.now().subtract(const Duration(hours: 5)),
      notes: 'Requerimos un lote grande para el almuerzo comunitario de 120 niños y adultos mayores.',
    ),
  ];

  List<SocialRequest> get socialRequests => List.unmodifiable(_socialRequests);

  void addSocialRequest(SocialRequest request) {
    _socialRequests.insert(0, request);
    notifyListeners();
  }

  void updateSocialRequestStatus(String requestId, String newStatus) {
    final idx = _socialRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _socialRequests[idx].status = newStatus;
      notifyListeners();
    }
  }
}
