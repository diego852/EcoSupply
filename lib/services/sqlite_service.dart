import '../models/app_models.dart';

/// Servicio de Base de Datos Local SQLite para EcoSupply.
///
/// Permite almacenar y consultar sin conexión:
/// - Publicaciones de Lotes (`publications`)
/// - Reservas y Códigos QR (`reservations`)
/// - Notificaciones (`notifications`)
/// - Historial de Cupo Mensual del Consumidor (`consumer_quota`)
class EcoSupplySqliteService {
  static final EcoSupplySqliteService _instance = EcoSupplySqliteService._internal();
  factory EcoSupplySqliteService() => _instance;
  EcoSupplySqliteService._internal();

  /// Sentencias SQL de Creación de Tablas SQLite (`ecosupply.db`)
  static const String createPublicationsTable = '''
    CREATE TABLE IF NOT EXISTS publications (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      itemsIncluded TEXT NOT NULL,
      totalItemsCount INTEGER NOT NULL,
      batchSize TEXT NOT NULL,
      modality TEXT NOT NULL,
      originalPrice REAL NOT NULL,
      discountedPrice REAL NOT NULL,
      batchQuantity INTEGER NOT NULL,
      category TEXT NOT NULL,
      businessName TEXT NOT NULL,
      businessAddress TEXT NOT NULL,
      expiryText TEXT NOT NULL,
      pickupSchedule TEXT NOT NULL,
      distanceText TEXT NOT NULL,
      imageUrl TEXT NOT NULL,
      rating REAL NOT NULL,
      isBusinessActive INTEGER NOT NULL
    );
  ''';

  static const String createReservationsTable = '''
    CREATE TABLE IF NOT EXISTS reservations (
      id TEXT PRIMARY KEY,
      productId TEXT NOT NULL,
      productTitle TEXT NOT NULL,
      batchSize TEXT NOT NULL,
      itemsIncluded TEXT NOT NULL,
      businessName TEXT NOT NULL,
      businessAddress TEXT NOT NULL,
      totalPrice REAL NOT NULL,
      status TEXT NOT NULL,
      date TEXT NOT NULL,
      pickupWindow TEXT NOT NULL,
      code TEXT NOT NULL,
      userEmail TEXT NOT NULL,
      userName TEXT NOT NULL,
      userRole TEXT NOT NULL,
      userLocation TEXT NOT NULL,
      distanceText TEXT NOT NULL,
      redeemedAt TEXT,
      redeemedByBusiness TEXT
    );
  ''';

  static const String createNotificationsTable = '''
    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      userEmail TEXT NOT NULL,
      isRead INTEGER NOT NULL
    );
  ''';

  /// Mapea un producto a un mapa compatible con SQLite
  Map<String, dynamic> productToSqliteMap(Product product) {
    return {
      'id': product.id,
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
      'isBusinessActive': product.isBusinessActive ? 1 : 0,
    };
  }

  /// Mapea una reserva a un mapa compatible con SQLite
  Map<String, dynamic> reservationToSqliteMap(Reservation reservation) {
    return {
      'id': reservation.id,
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
      'userLocation': reservation.userLocation,
      'distanceText': reservation.distanceText,
      'redeemedAt': reservation.redeemedAt?.toIso8601String(),
      'redeemedByBusiness': reservation.redeemedByBusiness,
    };
  }
}
