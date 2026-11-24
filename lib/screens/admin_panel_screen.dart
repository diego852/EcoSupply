import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  void _rejectWithReasonDialog(BuildContext context, UserProfile profile, AppState appState) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rechazar Solicitud de Registro', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indica el motivo obligatorio de rechazo para ${profile.fullName}:', style: const TextStyle(fontSize: 13, color: EcoTheme.textMuted)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo *',
                hintText: 'Ej. Ficha RUC no se encuentra en estado Habido o la foto de la fachada no corresponde a la ubicación...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                appState.rejectUserAccount(profile.uid, reason);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Solicitud de ${profile.fullName} rechazada.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debes ingresar un motivo de rechazo.')),
                );
              }
            },
            child: const Text('Confirmar Rechazo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingUsers = appState.registeredUserProfiles.where((p) => p.status == AccountStatus.pendiente).toList();
    final approvedUsers = appState.registeredUserProfiles.where((p) => p.status == AccountStatus.activa).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración EcoSupply'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Métrica resumen admin
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Solicitudes Pendientes', style: TextStyle(fontSize: 12, color: EcoTheme.textMuted)),
                          const SizedBox(height: 4),
                          Text('${pendingUsers.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: EcoTheme.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: EcoTheme.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cuentas Aprobadas', style: TextStyle(fontSize: 12, color: EcoTheme.textMuted)),
                          const SizedBox(height: 4),
                          Text('${approvedUsers.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Solicitudes Pendientes de Verificación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
              ),
              const SizedBox(height: 12),

              pendingUsers.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Center(
                        child: Text('No hay solicitudes pendientes por revisar'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingUsers.length,
                      itemBuilder: (context, index) {
                        final profile = pendingUsers[index];
                        final isBusiness = profile.role == UserRole.business;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: EcoTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        profile.role.displayName,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        profile.status.displayName,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  profile.fullName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Email: ${profile.email} • Tel: ${profile.phone}',
                                  style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                                ),
                                if (profile.ruc.isNotEmpty)
                                  Text('RUC: ${profile.ruc}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark)),
                                if (profile.dni.isNotEmpty)
                                  Text('DNI: ${profile.dni}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('Ubicación: ${profile.address}, ${profile.district}, ${profile.province}, ${profile.department}', style: const TextStyle(fontSize: 12, color: EcoTheme.textDark)),

                                if (profile.sisfohClassification != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Clasificación SISFOH: ${profile.sisfohClassification!.displayName}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.primary),
                                  ),
                                ],

                                // Mini Mapa de Ubicación del Comercio para Administrador
                                if (isBusiness && profile.latitude != null && profile.longitude != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.pin_drop_rounded, size: 16, color: EcoTheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Coordenadas GPS: ${profile.latitude!.toStringAsFixed(5)}, ${profile.longitude!.toStringAsFixed(5)}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: EcoTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 120,
                                      child: FlutterMap(
                                        options: MapOptions(
                                          initialCenter: LatLng(profile.latitude!, profile.longitude!),
                                          initialZoom: 15.0,
                                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName: 'com.example.untitled',
                                          ),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point: LatLng(profile.latitude!, profile.longitude!),
                                                child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                // Documentos Adjuntos
                                const SizedBox(height: 12),
                                const Text('Documentos de Verificación Adjuntos:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Column(
                                  children: profile.attachedDocuments.map((doc) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            doc.fileType.contains('pdf') ? Icons.picture_as_pdf : Icons.image,
                                            size: 18,
                                            color: EcoTheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('${doc.fileName} (${doc.fileSizeMb} MB)', style: const TextStyle(fontSize: 12))),
                                          const Icon(Icons.remove_red_eye_outlined, size: 18, color: EcoTheme.primary),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _rejectWithReasonDialog(context, profile, appState),
                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Rechazar'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          appState.approveUserAccount(profile.uid);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('¡Cuenta de ${profile.fullName} APROBADA!')),
                                          );
                                        },
                                        child: const Text('Aprobar Cuenta'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
