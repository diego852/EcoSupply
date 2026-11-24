import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  bool _isLoadingAddress = false;

  // Centro de Piura, Perú por defecto
  static final LatLng _piuraDefaultCenter = LatLng(-5.1945, -80.6328);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? _piuraDefaultCenter;
  }

  void _confirmLocation() async {
    setState(() => _isLoadingAddress = true);

    final result = await NominatimGeocodingService.reverseGeocode(
      lat: _selectedLocation.latitude,
      lon: _selectedLocation.longitude,
    );

    setState(() => _isLoadingAddress = false);

    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  void _useCurrentLocation() {
    // Centrar en ubicación por defecto de Piura o actual
    setState(() {
      _selectedLocation = _piuraDefaultCenter;
    });
    _mapController.move(_selectedLocation, 15.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mapa centrado en Piura. Toca en el mapa para marcar tu local exacto.'),
      ),
    );
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
              initialZoom: 14.5,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
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
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: Column(
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
                          size: 36,
                        ),
                      ],
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
              onPressed: _useCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: EcoTheme.primary,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Centrar en Piura', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          // Barra inferior para confirmar
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
