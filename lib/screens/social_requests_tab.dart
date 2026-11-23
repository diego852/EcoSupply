import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SocialRequestsTab extends StatefulWidget {
  const SocialRequestsTab({super.key});

  @override
  State<SocialRequestsTab> createState() => _SocialRequestsTabState();
}

class _SocialRequestsTabState extends State<SocialRequestsTab> {
  void _openCreateRequestDialog(BuildContext context) {
    final foodTypeController = TextEditingController();
    final peopleController = TextEditingController(text: '100');
    final notesController = TextEditingController();
    String urgency = 'Alta';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Crear Solicitud de Alimentos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Especifica los insumos que requiere tu comedor o comunidad:',
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: foodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Alimento Necesitado',
                    hintText: 'Ej. Arroz, menestras, verduras, pollo',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: peopleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de Raciones / Beneficiarios',
                    hintText: '100',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Nivel de Urgencia:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: ['Alta', 'Media', 'Normal'].map((u) {
                    final isSel = urgency == u;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => urgency = u),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? EcoTheme.primary : EcoTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            u,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : EcoTheme.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Detalles adicionales / Notas',
                    hintText: 'Para el almuerzo popular de esta semana...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (foodTypeController.text.trim().isNotEmpty) {
                  final appState = Provider.of<AppState>(context, listen: false);
                  final req = SocialRequest(
                    id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                    orgName: appState.orgName,
                    foodType: foodTypeController.text.trim(),
                    peopleServed: int.tryParse(peopleController.text) ?? 50,
                    urgency: urgency,
                    status: 'Pendiente',
                    requestDate: DateTime.now(),
                    notes: notesController.text.trim(),
                  );

                  appState.addSocialRequest(req);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Solicitud publicada para comercios aliados'),
                      backgroundColor: EcoTheme.primary,
                    ),
                  );
                }
              },
              child: const Text('Publicar Solicitud'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Donación Recibidas / Enviadas'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateRequestDialog(context),
        backgroundColor: EcoTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva Solicitud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appState.socialRequests.length,
        itemBuilder: (context, index) {
          final req = appState.socialRequests[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req.orgName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: EcoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          req.status,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: EcoTheme.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    req.foodType,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcoTheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atención a ${req.peopleServed} beneficiarios • Urgencia: ${req.urgency}',
                    style: const TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                  ),
                  if (req.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      req.notes,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: EcoTheme.textDark),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
