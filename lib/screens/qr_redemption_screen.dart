import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/qr_code_widget.dart';

class QrRedemptionScreen extends StatelessWidget {
  final Reservation reservation;

  const QrRedemptionScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = reservation.status == 'confirmada' || reservation.status == 'Lista para recoger';
    final isRetirada = reservation.status == 'retirada' || reservation.status == 'Completada';
    final isPending = reservation.status == 'pendiente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR de Recogida'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Encabezado del Establecimiento
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: EcoTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront_rounded, color: EcoTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reservation.businessName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: EcoTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reservation.businessAddress,
                                style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reservation.batchSize.badgeLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: EcoTheme.primaryDark),
                        ),
                        Text(
                          'Horario: ${reservation.pickupWindow}',
                          style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Contenido del QR según estado
              if (isConfirmed) ...[
                const Text(
                  'Presenta este Código QR en Tienda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'El personal del establecimiento lo escaneará para registrar la entrega de tu lote completo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 24),

                // Generador de QR
                QrCodeWidget(
                  data: reservation.qrPayload,
                  size: 210,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: EcoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Código Manual: ${reservation.code}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EcoTheme.primaryDark,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ] else if (isRetirada) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.blue, size: 75),
                      const SizedBox(height: 12),
                      const Text(
                        '¡Lote Retirado con Éxito!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Este lote fue entregado en ${reservation.businessName} ${reservation.redeemedAt != null ? "el ${reservation.redeemedAt!.day}/${reservation.redeemedAt!.month}/${reservation.redeemedAt!.year} a las ${reservation.redeemedAt!.hour}:${reservation.redeemedAt!.minute.toString().padLeft(2, '0')}." : "exitosamente."}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: EcoTheme.textDark),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'El código QR se invalida automáticamente tras ser escaneado para evitar un segundo retiro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ] else if (isPending) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 75),
                      SizedBox(height: 12),
                      Text(
                        'Solicitud Pendiente de Aprobación',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tu solicitud aún no ha sido aceptada por el establecimiento. El código QR de recogida se habilitará inmediatamente cuando el comercio confirme tu pedido.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: EcoTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.block_rounded, color: Colors.red, size: 75),
                      const SizedBox(height: 12),
                      Text(
                        'Reserva ${reservation.status.toUpperCase()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No es posible generar un código QR para solicitudes rechazadas, canceladas o vencidas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: EcoTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Detalle del Contenido
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles de la Reserva',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lote: ${reservation.productTitle}',
                      style: const TextStyle(fontSize: 13, color: EcoTheme.textDark),
                    ),
                    Text(
                      'Contenido: ${reservation.itemsIncluded}',
                      style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Solicitante: ${reservation.userName} (${reservation.userEmail})',
                      style: const TextStyle(fontSize: 12, color: EcoTheme.textDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver a Mis Reservas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
