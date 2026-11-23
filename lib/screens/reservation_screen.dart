import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ReservationScreen extends StatefulWidget {
  final Product product;

  const ReservationScreen({super.key, required this.product});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late String _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _selectedTimeSlot = widget.product.pickupSchedule.isNotEmpty
        ? widget.product.pickupSchedule
        : '5:00 PM - 7:00 PM';
  }

  String _generateReservationCode() {
    final random = Random();
    final number = 1000 + random.nextInt(9000);
    return 'ECO-$number';
  }

  void _confirmBatchReservation() {
    final appState = Provider.of<AppState>(context, listen: false);
    final code = _generateReservationCode();

    final newReservation = Reservation(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      productId: widget.product.id,
      productTitle: widget.product.title,
      batchSize: widget.product.batchSize,
      itemsIncluded: widget.product.itemsIncluded,
      businessName: widget.product.businessName,
      businessAddress: widget.product.businessAddress,
      totalPrice: widget.product.discountedPrice, // 1 lote completo
      status: 'pendiente', // Inicia en estado 'pendiente'
      date: DateTime.now(),
      pickupWindow: _selectedTimeSlot,
      code: code,
      userEmail: appState.userEmail,
      userName: appState.userName,
      userRole: appState.currentRole,
    );

    appState.addReservation(newReservation);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 60),
            SizedBox(height: 12),
            Text(
              'Solicitud de Lote Enviada',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu solicitud para 1 ${widget.product.batchSize.displayName} de "${widget.product.title}" ha sido enviada a ${widget.product.businessName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: EcoTheme.textDark),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Column(
                children: [
                  Text(
                    'Estado: Pendiente de Aprobación',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'El establecimiento revisará tu solicitud. Recibirás una notificación cuando sea aceptada o rechazada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra modal
                Navigator.of(context).pop(); // Cierra detalle
              },
              child: const Text('Ver en Mis Reservas'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmación de Solicitud de Lote'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen del Lote
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.product.batchSize == BatchSize.small
                                ? EcoTheme.primaryLight
                                : Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.product.batchSize.badgeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.product.batchSize == BatchSize.small
                                  ? EcoTheme.primaryDark
                                  : Colors.deepPurple,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.product.modality.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: EcoTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.product.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Incluye: ${widget.product.itemsIncluded}',
                      style: const TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Establecimiento:', style: TextStyle(fontSize: 13, color: EcoTheme.textMuted)),
                        Text(widget.product.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Indicador de Reserva de Lote Completo (No unidades sueltas)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EcoTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EcoTheme.primary),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.all_inbox_rounded, color: EcoTheme.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reserva por Lote Completo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.primaryDark),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Estás reservando 1 lote cerrado con todo el contenido especificado.',
                            style: TextStyle(fontSize: 12, color: EcoTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Datos del Solicitante
              const Text(
                'Datos del Solicitante',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nombre:', style: TextStyle(color: EcoTheme.textMuted, fontSize: 13)),
                        Text(appState.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Correo:', style: TextStyle(color: EcoTheme.textMuted, fontSize: 13)),
                        Text(appState.userEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rol:', style: TextStyle(color: EcoTheme.textMuted, fontSize: 13)),
                        Text(appState.currentRole.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: EcoTheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Método de Pago / Recogida
              const Text(
                'Método de Pago en Tienda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_rounded, color: EcoTheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.isDonation
                                ? 'Donación Gratuita'
                                : 'Pago presencial en tienda al recoger el lote',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.product.isDonation
                                ? 'Presenta tu código QR para retiro sin costo al ser aprobada'
                                : 'Acepta Efectivo, Yape o Plin al recoger',
                            style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: EcoTheme.primary),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Resumen Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EcoTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total 1 Lote Completo:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.product.isDonation ? 'GRATIS' : 'S/ ${widget.product.discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: EcoTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmBatchReservation,
                  child: const Text('Enviar Solicitud de Reserva'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
