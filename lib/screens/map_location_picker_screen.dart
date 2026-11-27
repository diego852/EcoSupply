import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/nominatim_geocoding_service.dart';
import '../theme/app_theme.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapLocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  bool _isGettingLocation = false;
  bool _isLoadingAddress = false;
  NominatimGeocodingResult? _geocodedResult;

  // Centro por defecto (Piura, Perú) si no se provee initialLocation
  static const double _defaultLat = -5.1945;
  static const double _defaultLng = -80.6328;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? const LatLng(_defaultLat, _defaultLng);

    // Si ya viene con una ubicación inicial, obtener su dirección por geocodificación inversa
    if (widget.initialLocation != null) {
      _fetchAddressForLocation(_selectedLocation);
    }
  }

  /// Realiza la geocodificación inversa para obtener Departamento, Provincia, Distrito y Dirección
  Future<void> _fetchAddressForLocation(LatLng location) async {
    setState(() => _isLoadingAddress = true);

    final result = await NominatimGeocodingService.reverseGeocode(
      lat: location.latitude,
      lon: location.longitude,
    );

    if (mounted) {
      setState(() {
        _geocodedResult = result;
        _isLoadingAddress = false;
      });
    }
  }

  /// Actualiza la ubicación seleccionada y ejecuta geocodificación inversa
  void _onLocationChanged(LatLng newLocation) {
    setState(() {
      _selectedLocation = newLocation;
    });
    _fetchAddressForLocation(newLocation);
  }

  /// Obtiene la ubicación real del dispositivo usando Geolocator
  Future<void> _useCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      // 2a. Verificar servicio de ubicación activo
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('El servicio de ubicación está desactivado.'),
              action: SnackBarAction(
                label: 'Ajustes',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      // 2b. Verificar y solicitar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permiso de ubicación denegado. Puedes seleccionar tu posición manualmente en el mapa.'),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permiso de ubicación denegado permanentemente. Actívalo en los ajustes de la app.'),
              action: SnackBarAction(
                label: 'Ajustes App',
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      // 2c. Obtén la posición con Geolocator (accuracy: high, timeLimit: 15s)
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      final newLocation = LatLng(position.latitude, position.longitude);

      // 2d. Mover mapa y marcador a la posición obtenida con zoom ~17
      setState(() {
        _selectedLocation = newLocation;
      });
      _mapController.move(newLocation, 17.0);

      // Geocodificación inversa con Nominatim
      await _fetchAddressForLocation(newLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos obtener tu ubicación. Mueve el marcador manualmente.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _confirmLocation() async {
    // Si la geocodificación no ha finalizado aún o no existe, hacerla ahora
    if (_geocodedResult == null ||
        _geocodedResult!.latitude != _selectedLocation.latitude ||
        _geocodedResult!.longitude != _selectedLocation.longitude) {
      await _fetchAddressForLocation(_selectedLocation);
    }

    if (mounted) {
      Navigator.pop(context, _geocodedResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del Local en Mapa'),
      ),
      body: Stack(
        children: [
          // Mapa Interactivo OpenStreetMap (flutter_map)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                _onLocationChanged(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.untitled',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 70,
                    height: 70,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) {
                        // Permite arrastrar el marcador libremente por la pantalla
                        final camera = _mapController.camera;
                        final point = camera.latLngToScreenPoint(_selectedLocation);
                        final newPoint = math.Point(point.x + details.delta.dx, point.y + details.delta.dy);
                        final newLatLng = camera.pointToLatLng(newPoint);
                        setState(() {
                          _selectedLocation = newLatLng;
                        });
                      },
                      onPanEnd: (_) {
                        // Al soltar el marcador arrastrado, rellenar datos vía geocodificación inversa
                        _fetchAddressForLocation(_selectedLocation);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: EcoTheme.primaryDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tu Local',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.redAccent,
                            size: 38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Botón flotante "Usar mi ubicación actual"
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'my_location_btn',
              onPressed: _isGettingLocation ? null : _useCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: EcoTheme.primary,
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: EcoTheme.primary,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                _isGettingLocation ? 'Obteniendo ubicación...' : 'Usar mi ubicación actual',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Barra inferior para mostrar la dirección detectada y confirmar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, color: EcoTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Coordenadas: ${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
                          ),
                        ),
                      ],
                    ),

                    if (_isLoadingAddress) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: EcoTheme.primary),
                          ),
                          SizedBox(width: 8),
                          Text('Obteniendo dirección...', style: TextStyle(fontSize: 12, color: EcoTheme.textMuted)),
                        ],
                      ),
                    ] else if (_geocodedResult != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: EcoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: EcoTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _geocodedResult!.address,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_geocodedResult!.district}, ${_geocodedResult!.province}, ${_geocodedResult!.department}',
                              style: const TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingAddress ? null : _confirmLocation,
                        icon: _isLoadingAddress
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(_isLoadingAddress ? 'Obteniendo Dirección...' : 'Confirmar Ubicación'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
