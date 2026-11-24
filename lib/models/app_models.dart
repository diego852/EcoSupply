enum UserRole {
  localUser,   // Usuario Local (Consumidor)
  business,    // Establecimiento (Comercio / Restaurante)
  socialOrg,   // Organización Social (Comedor / Banco)
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.localUser:
        return 'Usuario Local (Consumidor)';
      case UserRole.business:
        return 'Establecimiento (Comercio)';
      case UserRole.socialOrg:
        return 'Organización Social (ONG)';
    }
  }

  String get description {
    switch (this) {
      case UserRole.localUser:
        return 'Reserva 1 lote pequeño al mes en Venta Social (Requiere SISFOH)';
      case UserRole.business:
        return 'Publica y vende o dona lotes de alimentos excedentes';
      case UserRole.socialOrg:
        return 'Accede a donaciones y lotes medianos/grandes para la comunidad';
    }
  }

  String get shortTag {
    switch (this) {
      case UserRole.localUser:
        return 'Consumidor';
      case UserRole.business:
        return 'Comercio';
      case UserRole.socialOrg:
        return 'ONG / Comedor';
    }
  }
}

enum AccountStatus {
  activa,     // Aprobada / Activa
  pendiente,  // En proceso de revisión por el administrador
  rechazada,  // Rechazada por el administrador
  suspendida, // Suspendida
  vencida,    // Vencida (cumplidos los 12 meses)
}

extension AccountStatusExtension on AccountStatus {
  String get displayName {
    switch (this) {
      case AccountStatus.activa:
        return 'Aprobada / Activa';
      case AccountStatus.pendiente:
        return 'Pendiente de Verificación';
      case AccountStatus.rechazada:
        return 'Rechazada';
      case AccountStatus.suspendida:
        return 'Suspendida';
      case AccountStatus.vencida:
        return 'Verificación Vencida (Reagendar)';
    }
  }

  bool get canReserve => this == AccountStatus.activa;
}

enum SisfohClassification {
  pobreExtremo,
  pobre,
  noPobre,
}

extension SisfohClassificationExtension on SisfohClassification {
  String get displayName {
    switch (this) {
      case SisfohClassification.pobreExtremo:
        return 'Pobre extremo';
      case SisfohClassification.pobre:
        return 'Pobre';
      case SisfohClassification.noPobre:
        return 'No pobre';
    }
  }

  bool get isEligible => this == SisfohClassification.pobreExtremo || this == SisfohClassification.pobre;
}

class DocumentAttachment {
  final String id;
  final String fileName;
  final String fileType; // 'image/jpeg', 'image/png', 'application/pdf'
  final double fileSizeMb;
  final DateTime uploadDate;

  DocumentAttachment({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSizeMb,
    required this.uploadDate,
  });
}

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String dni;
  final String ruc;
  final UserRole role;
  final String businessType;
  final String orgType;
  final String department;
  final String province;
  final String district;
  final String address;
  final double? latitude;
  final double? longitude;
  AccountStatus status;
  final SisfohClassification? sisfohClassification;
  final List<DocumentAttachment> attachedDocuments;
  DateTime? approvalDate;
  DateTime? expirationDate;
  String? rejectionReason;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.dni = '',
    this.ruc = '',
    required this.role,
    this.businessType = '',
    this.orgType = '',
    this.department = 'Piura',
    this.province = 'Piura',
    required this.district,
    required this.address,
    this.latitude,
    this.longitude,
    required this.status,
    this.sisfohClassification,
    required this.attachedDocuments,
    this.approvalDate,
    this.expirationDate,
    this.rejectionReason,
  });
}

enum OngAccreditationStatus {
  accredited, // Acreditada
  pending,    // Pendiente
  rejected,   // Rechazada
  suspended,  // Suspendida
  expired,    // Vencida
}

extension OngAccreditationStatusExtension on OngAccreditationStatus {
  String get displayName {
    switch (this) {
      case OngAccreditationStatus.accredited:
        return 'Acreditada';
      case OngAccreditationStatus.pending:
        return 'Pendiente';
      case OngAccreditationStatus.rejected:
        return 'Rechazada';
      case OngAccreditationStatus.suspended:
        return 'Suspendida';
      case OngAccreditationStatus.expired:
        return 'Acreditación Vencida';
    }
  }

  bool get canRequestDonations => this == OngAccreditationStatus.accredited;
}

enum BatchSize {
  small,  // Lote pequeño
  medium, // Lote mediano
  large,  // Lote grande
}

extension BatchSizeExtension on BatchSize {
  String get displayName {
    switch (this) {
      case BatchSize.small:
        return 'Lote pequeño';
      case BatchSize.medium:
        return 'Lote mediano';
      case BatchSize.large:
        return 'Lote grande';
    }
  }

  String get description {
    switch (this) {
      case BatchSize.small:
        return 'Disponible para Consumidores (Venta Social, máx. 1/mes) y ONGs.';
      case BatchSize.medium:
        return 'Exclusivo para Organizaciones Sociales Acreditadas.';
      case BatchSize.large:
        return 'Exclusivo para Organizaciones Sociales y Bancos Acreditados.';
    }
  }

  String get badgeLabel {
    switch (this) {
      case BatchSize.small:
        return 'Lote Pequeño';
      case BatchSize.medium:
        return 'Lote Mediano (ONG)';
      case BatchSize.large:
        return 'Lote Grande (ONG)';
    }
  }
}

enum Modality {
  socialSale,   // Venta Social
  freeDonation, // Donación Gratuita
}

extension ModalityExtension on Modality {
  String get displayName {
    switch (this) {
      case Modality.socialSale:
        return 'Venta Social';
      case Modality.freeDonation:
        return 'Donación Gratuita';
    }
  }
}

class Product {
  final String id;
  final String title;
  final String itemsIncluded;     // Alimentos específicos que incluye el lote
  final int totalItemsCount;       // Cantidad informativa total de unidades dentro del lote
  final BatchSize batchSize;       // Lote pequeño, mediano, grande
  final Modality modality;         // Venta Social o Donación Gratuita
  final double originalPrice;      // Precio original del lote
  final double discountedPrice;    // Precio social del lote completo (0.00 en donación)
  int batchQuantity;               // Stock en número de lotes completos disponibles
  final String category;
  final String businessName;
  final String businessAddress;
  final String expiryText;
  final String pickupSchedule;
  final String distanceText;
  final String imageUrl;
  final double rating;
  final bool isBusinessActive;     // Si el establecimiento está activo

  bool get isDonation => modality == Modality.freeDonation;
  bool get isSmallBatchDonation => isDonation && batchSize == BatchSize.small;

  Product({
    required this.id,
    required this.title,
    required this.itemsIncluded,
    required this.totalItemsCount,
    required this.batchSize,
    required this.modality,
    required this.originalPrice,
    required this.discountedPrice,
    required this.batchQuantity,
    required this.category,
    required this.businessName,
    required this.businessAddress,
    required this.expiryText,
    required this.pickupSchedule,
    this.distanceText = '1.0 km',
    required this.imageUrl,
    this.rating = 4.8,
    this.isBusinessActive = true,
  });
}

class Reservation {
  final String id;
  final String productId;
  final String productTitle;
  final BatchSize batchSize;
  final String itemsIncluded;
  final String businessName;
  final String businessAddress;
  final double totalPrice;
  String status; // 'pendiente', 'confirmada', 'rechazada', 'cancelada', 'vencida', 'retirada'
  final DateTime date;
  final String pickupWindow;
  final String code;
  final String userEmail;
  final String userName;
  final String userDni;
  final UserRole userRole;
  final String userLocation; // Ubicación donde se creó la cuenta / solicitud
  final String distanceText; // Distancia calculada en km
  DateTime? redeemedAt;
  String? redeemedByBusiness;

  /// Genera la cadena de payload segura para el código QR
  String get qrPayload => 'ECOSUPPLY|$id|$code|$businessName';

  Reservation({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.batchSize,
    required this.itemsIncluded,
    required this.businessName,
    required this.businessAddress,
    required this.totalPrice,
    required this.status,
    required this.date,
    required this.pickupWindow,
    required this.code,
    required this.userEmail,
    required this.userName,
    this.userDni = '',
    required this.userRole,
    this.userLocation = 'Miraflores, Lima',
    this.distanceText = '0.8 km',
    this.redeemedAt,
    this.redeemedByBusiness,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String userEmail;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.userEmail,
    this.isRead = false,
  });
}

class SocialRequest {
  final String id;
  final String orgName;
  final String foodType;
  final int peopleServed;
  final String urgency; // 'Alta', 'Media', 'Normal'
  String status;        // 'Pendiente', 'En Proceso', 'Atendida'
  final DateTime requestDate;
  final String notes;

  SocialRequest({
    required this.id,
    required this.orgName,
    required this.foodType,
    required this.peopleServed,
    required this.urgency,
    required this.status,
    required this.requestDate,
    required this.notes,
  });
}
