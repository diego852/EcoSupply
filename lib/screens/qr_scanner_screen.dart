import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _processScannedCode(String rawPayload, AppState appState) {
    if (rawPayload.trim().isEmpty) return;

    final result = appState.validateAndRedeemBatchQr(
      rawPayload: rawPayload,
      scanningBusinessName: appState.businessName,
    );

    if (result.isValid && result.reservation != null) {
      final res = result.reservation!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle_rounded, color: EcoTheme.primary, size: 60),
              SizedBox(height: 8),
              Text(
                '¡Entrega Registrada con Éxito!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EcoTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.batchSize.badgeLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: EcoTheme.primaryDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      res.productTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: EcoTheme.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contenido: ${res.itemsIncluded}',
                      style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Solicitante: ${res.userName} (${res.userRole.displayName})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                'Email: ${res.userEmail}',
                style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                res.totalPrice == 0
                    ? 'Modalidad: Donación Gratuita'
                    : 'Monto cobrado en tienda: S/ ${res.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.primary),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _codeController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      );
    } else {
      // Error de validación / Anti-doble canje / QR inválido
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text('Validación Fallida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: Text(
            result.message,
            style: const TextStyle(fontSize: 14, color: EcoTheme.textDark, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner QR de Establecimiento'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                appState.businessName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
              ),
              const SizedBox(height: 4),
              const Text(
                'Escanea el código QR del cliente para registrar la entrega de 1 Lote Completo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
              ),
              const SizedBox(height: 24),

              // Visor de Cámara / Marco de Escáner Animado
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: EcoTheme.primary, width: 3),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white24,
                      size: 100,
                    ),
                    // Línea de escaneo animada
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _scanAnimation.value * 220,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: EcoTheme.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: EcoTheme.accent.withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.center_focus_strong, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Cámara Activa',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Ingreso / Simulación Manual de Código QR
              const Text(
                'O Ingresa el Código Manualmente:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.textDark),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Código / Payload QR',
                  hintText: 'Ej. ECO-8492 o payload completo',
                  prefixIcon: const Icon(Icons.qr_code_rounded, color: EcoTheme.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: EcoTheme.primary),
                    onPressed: () => _processScannedCode(_codeController.text, appState),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _processScannedCode(_codeController.text, appState),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Validar y Registrar Entrega'),
                ),
              ),
              const SizedBox(height: 24),

              // Lista de Reservas Listas para Recoger (Acceso Rápido para Pruebas)
              if (appState.reservations.any((r) => r.status == 'confirmada' || r.status == 'Lista para recoger')) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lotes Confirmados Listos para Recojo:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.textDark),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: appState.reservations
                      .where((r) => r.status == 'confirmada' || r.status == 'Lista para recoger')
                      .map((res) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text('${res.code} • ${res.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${res.batchSize.displayName} • ${res.productTitle}', style: const TextStyle(fontSize: 11)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () {
                            _codeController.text = res.qrPayload;
                            _processScannedCode(res.qrPayload, appState);
                          },
                          child: const Text('Escanear', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
