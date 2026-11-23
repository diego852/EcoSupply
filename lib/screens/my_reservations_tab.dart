import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'qr_redemption_screen.dart';

class MyReservationsTab extends StatefulWidget {
  const MyReservationsTab({super.key});

  @override
  State<MyReservationsTab> createState() => _MyReservationsTabState();
}

class _MyReservationsTabState extends State<MyReservationsTab> {
  String _filterStatus = 'Todas';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final filtered = appState.reservations.where((res) {
      if (_filterStatus == 'Todas') return true;
      if (_filterStatus == 'Pendientes') return res.status == 'pendiente';
      if (_filterStatus == 'Confirmadas') return res.status == 'confirmada' || res.status == 'Lista para recoger';
      if (_filterStatus == 'Historial') return res.status == 'retirada' || res.status == 'Completada' || res.status == 'rechazada' || res.status == 'cancelada' || res.status == 'vencida';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas de Lotes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner de estado de cupo mensual si es consumidor local
          if (appState.currentRole == UserRole.localUser) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: appState.hasUsedMonthlyQuota(appState.userEmail)
                  ? Colors.orange.shade50
                  : EcoTheme.primaryLight,
              child: Row(
                children: [
                  Icon(
                    appState.hasUsedMonthlyQuota(appState.userEmail)
                        ? Icons.info_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: appState.hasUsedMonthlyQuota(appState.userEmail)
                        ? Colors.orange.shade800
                        : EcoTheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appState.hasUsedMonthlyQuota(appState.userEmail)
                          ? 'Has reservado tu 1 lote pequeño de este mes. Próximo cupo disponible: 1/${appState.getNextQuotaAvailableDate().month}/${appState.getNextQuotaAvailableDate().year}'
                          : 'Tienes disponible tu cupo mensual para 1 Lote Pequeño en Venta Social.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: appState.hasUsedMonthlyQuota(appState.userEmail)
                            ? Colors.orange.shade900
                            : EcoTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Filtros por Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: ['Todas', 'Pendientes', 'Confirmadas', 'Historial'].map((status) {
                final isSelected = _filterStatus == status;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filterStatus = status),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? EcoTheme.primary : EcoTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : EcoTheme.primaryDark,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Lista de Reservas de Lotes
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 60, color: EcoTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No tienes reservas en "$_filterStatus"',
                          style: const TextStyle(color: EcoTheme.textMuted, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final reservation = filtered[index];
                      return _ReservationBatchCard(reservation: reservation);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReservationBatchCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationBatchCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    Color statusColor;
    String statusLabel;
    switch (reservation.status) {
      case 'pendiente':
        statusColor = Colors.orange;
        statusLabel = 'Pendiente de Aprobación';
        break;
      case 'confirmada':
      case 'Lista para recoger':
        statusColor = EcoTheme.primary;
        statusLabel = 'Confirmada - Listo para Recoger';
        break;
      case 'rechazada':
        statusColor = Colors.red;
        statusLabel = 'Rechazada por Establecimiento';
        break;
      case 'cancelada':
        statusColor = Colors.grey;
        statusLabel = 'Cancelada';
        break;
      case 'retirada':
      case 'Completada':
        statusColor = Colors.blue;
        statusLabel = 'Retirada en Tienda';
        break;
      case 'vencida':
        statusColor = Colors.red.shade800;
        statusLabel = 'Vencida';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = reservation.status;
    }

    final isConfirmed = reservation.status == 'confirmada' || reservation.status == 'Lista para recoger';
    final isPending = reservation.status == 'pendiente';

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
                    reservation.batchSize.badgeLabel,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              reservation.productTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: EcoTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contenido: ${reservation.itemsIncluded}',
              style: const TextStyle(fontSize: 13, color: EcoTheme.textMuted),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.storefront_rounded, size: 16, color: EcoTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  reservation.businessName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: EcoTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Horario: ${reservation.pickupWindow}',
                  style: const TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EcoTheme.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Código de Recogida',
                        style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                      ),
                      Text(
                        reservation.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: EcoTheme.primaryDark,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '1 Lote Completo',
                        style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                      ),
                      Text(
                        reservation.totalPrice == 0
                            ? 'GRATIS'
                            : 'S/ ${reservation.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: EcoTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (isConfirmed) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrRedemptionScreen(reservation: reservation),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_rounded),
                      label: const Text('Ver Código QR'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      appState.cancelReservation(reservation.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reserva cancelada. Se restauró el lote al stock y el cupo fue liberado.'),
                        ),
                      );
                    },
                    child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ] else if (isPending) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    appState.cancelReservation(reservation.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitud pendiente cancelada.'),
                      ),
                    );
                  },
                  child: const Text('Cancelar Solicitud Pendiente', style: TextStyle(color: Colors.red)),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrRedemptionScreen(reservation: reservation),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('Ver Detalle de Reserva'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
