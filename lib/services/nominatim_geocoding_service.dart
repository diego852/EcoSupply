import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimGeocodingResult {
  final String department;
  final String province;
  final String district;
  final String address;
  final double latitude;
  final double longitude;
  final bool isSuccess;
  final String? errorMessage;

  NominatimGeocodingResult({
    required this.department,
    required this.province,
    required this.district,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isSuccess,
    this.errorMessage,
  });
}

class NominatimGeocodingService {
  static DateTime? _lastRequestTime;

  /// Normaliza nombres de localidades eliminando prefijos como "Departamento de", "Provincia de", "Distrito de"
  static String normalizeLocationName(String text) {
    if (text.trim().isEmpty) return '';
    String cleaned = text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'^(Departamento|Provincia|Distrito)\s+(de|del)\s+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'^(Departamento|Provincia|Distrito)\s+', caseSensitive: false), '');
    cleaned = cleaned.trim();
    if (cleaned.isNotEmpty) {
      return cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    return cleaned;
  }

  /// Realiza geocodificación inversa vía Nominatim OpenStreetMap API con throttle de 1 req/seg y User-Agent personalizado
  static Future<NominatimGeocodingResult> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    // Throttle de 1 segundo entre solicitudes (política Nominatim)
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }
    }
    _lastRequestTime = DateTime.now();

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&addressdetails=1&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'EcoSupplyApp/1.0 (contact: info@ecosupply.pe)',
          'Accept-Language': 'es',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final addr = data['address'] as Map<String, dynamic>? ?? {};

        final rawState = (addr['state'] ?? addr['region'] ?? 'Piura').toString();
        final rawCounty = (addr['county'] ?? addr['region'] ?? addr['state_district'] ?? 'Piura').toString();
        final rawDistrict = (addr['city_district'] ??
                addr['suburb'] ??
                addr['town'] ??
                addr['city'] ??
                addr['municipality'] ??
                'Piura')
            .toString();

        final department = normalizeLocationName(rawState);
        final province = normalizeLocationName(rawCounty);
        final district = normalizeLocationName(rawDistrict);

        final road = (addr['road'] ?? addr['pedestrian'] ?? addr['suburb'] ?? '').toString();
        final houseNum = (addr['house_number'] ?? '').toString();

        String addressLine = '';
        if (road.isNotEmpty) {
          addressLine = houseNum.isNotEmpty ? '$road $houseNum' : road;
        } else {
          addressLine = (data['display_name'] ?? '').toString().split(',').first;
        }

        return NominatimGeocodingResult(
          department: department.isNotEmpty ? department : 'Piura',
          province: province.isNotEmpty ? province : 'Piura',
          district: district.isNotEmpty ? district : 'Piura',
          address: addressLine.isNotEmpty ? addressLine : 'Dirección seleccionada en mapa',
          latitude: lat,
          longitude: lon,
          isSuccess: true,
        );
      } else {
        return NominatimGeocodingResult(
          department: 'Piura',
          province: 'Piura',
          district: 'Piura',
          address: '',
          latitude: lat,
          longitude: lon,
          isSuccess: false,
          errorMessage: 'No pudimos obtener la dirección, complétala manualmente',
        );
      }
    } catch (e) {
      return NominatimGeocodingResult(
        department: 'Piura',
        province: 'Piura',
        district: 'Piura',
        address: '',
        latitude: lat,
        longitude: lon,
        isSuccess: false,
        errorMessage: 'No pudimos obtener la dirección, complétala manualmente',
      );
    }
  }
}
