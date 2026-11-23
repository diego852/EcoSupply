import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/qr_code_widget.dart';
import 'publish_product_screen.dart';
import 'qr_scanner_screen.dart';

class ReceivedRequestsTab extends StatefulWidget {
  const ReceivedRequestsTab({super.key});

  @override
  State<ReceivedRequestsTab> createState() => _ReceivedRequestsTabState();
}

class _ReceivedRequestsTabState extends State<ReceivedRequestsTab> {
  int _selectedTabIndex = 0; // 0: Reservas de Lotes, 1: Peticiones ONGs
  String _selectedKpiFilter = 'pendientes'; // 'publicados', 'pendientes', 'listos', 'entregas'
  String _deliveryTimeFilter = 'Este Mes'; // 'Hoy', 'Este Mes', 'Este Año'

  void _showQrGeneratedDialog(BuildContext context, Reservation res) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.qr_code_2_rounded, color: EcoTheme.primary, size: 50),
            SizedBox(height: 8),
            Text(
              '¡Código QR Generado Automáticamente!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Has ACEPTADO la solicitud de ${res.userName}. Se generó automáticamente el código QR único para la entrega de 1 ${res.batchSize.displayName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: EcoTheme.textDark),
            ),
            const SizedBox(height: 16),
            QrCodeWidget(data: res.qrPayload, size: 160),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: EcoTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Código de Recojo: ${res.code}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: EcoTheme.primaryDark,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'El cliente ha recibido una notificación y este código QR en su aplicación para mostrarlo al momento del recojo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }

  // Modal para ver el QR generado de un lote listo
  void _showAcceptedQrDetailDialog(BuildContext context, Reservation res, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.qr_code_rounded, color: EcoTheme.primary, size: 45),
            const SizedBox(height: 6),
            Text(
              'Lote Listo para Entrega',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              res.code,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: EcoTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    res.batchSize.badgeLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: EcoTheme.primaryDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    res.productTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.textDark),
                  ),
                  Text(
                    'Solicitante: ${res.userName} (${res.userRole.shortTag})',
                    style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            QrCodeWidget(data: res.qrPayload, size: 160),
            const SizedBox(height: 12),
            const Text(
              'Código QR activo y validado en base de datos. Escanéalo cuando el cliente llegue a la tienda para registrar la entrega.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: EcoTheme.textMuted),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    appState.updateReservationStatus(res.id, 'retirada');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lote ${res.code} entregado con éxito.')),
                    );
                  },
                  child: const Text('Registrar Entrega'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text('Solicitudes de Lotes Recibidas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Escanear QR de Cliente',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de Pestaña Superior (Reservas de Lotes vs Peticiones ONGs)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0 ? EcoTheme.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        'Reservas de Lotes (${appState.reservations.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedTabIndex == 0 ? EcoTheme.primary : EcoTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1 ? EcoTheme.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        'Peticiones ONGs (${appState.socialRequests.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedTabIndex == 1 ? EcoTheme.primary : EcoTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la pestaña activa
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildBatchReservationsTab(context, appState)
                : _buildSocialRequestsTab(context, appState),
          ),
        ],
      ),
    );
  }

  // Pestaña 1: Reservas de Lotes con KPIs Interactivos
  Widget _buildBatchReservationsTab(BuildContext context, AppState appState) {
    final pendingReservations = appState.reservations.where((r) => r.status == 'pendiente').toList();
    final confirmedReservations = appState.reservations.where((r) => r.status == 'confirmada' || r.status == 'Lista para recoger').toList();
    final publishedProducts = appState.products.where((p) => p.businessName == appState.businessName || p.businessName.contains('Don Lucho')).toList();

    // Filtrar entregas según el rango de tiempo seleccionado
    final now = DateTime.now();
    final allDelivered = appState.reservations.where((r) {
      if (r.status != 'retirada' && r.status != 'Completada') return false;
      final date = r.redeemedAt ?? r.date;
      if (_deliveryTimeFilter == 'Hoy') {
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (_deliveryTimeFilter == 'Este Mes') {
        return date.year == now.year && date.month == now.month;
      } else {
        return date.year == now.year;
      }
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu impacto en tiempo real',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Grid de Tarjetas KPI Interactivas
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKpiFilter = 'publicados'),
                  child: _KpiCard(
                    icon: Icons.article_outlined,
                    iconBgColor: const Color(0xFFE8F3E9),
                    iconColor: const Color(0xFF1B5E20),
                    value: '${publishedProducts.length}',
                    label: 'publicados',
                    isSelected: _selectedKpiFilter == 'publicados',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKpiFilter = 'pendientes'),
                  child: _KpiCard(
                    icon: Icons.access_time_rounded,
                    iconBgColor: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFF57F17),
                    value: '${pendingReservations.length}',
                    label: 'pendientes',
                    isSelected: _selectedKpiFilter == 'pendientes',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKpiFilter = 'listos'),
                  child: _KpiCard(
                    icon: Icons.check_circle_outlined,
                    iconBgColor: const Color(0xFFE1F5FE),
                    iconColor: const Color(0xFF0288D1),
                    value: '${confirmedReservations.length}',
                    label: 'listos',
                    isSelected: _selectedKpiFilter == 'listos',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKpiFilter = 'entregas'),
                  child: _KpiCard(
                    icon: Icons.eco_outlined,
                    iconBgColor: const Color(0xFFE8F3E9),
                    iconColor: const Color(0xFF1B5E20),
                    value: '${allDelivered.length}',
                    label: 'entregas',
                    isSelected: _selectedKpiFilter == 'entregas',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botones de Acción (+ Publicar alimento / Escanear QR)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PublishProductScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                    label: const Text(
                      'Publicar alimento',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Colors.white),
                    label: const Text(
                      'Escanear QR',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Título de Sección Dinámico según la Tarjeta Seleccionada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedKpiFilter == 'publicados'
                    ? 'Lotes publicados activos'
                    : _selectedKpiFilter == 'pendientes'
                        ? 'Solicitudes pendientes'
                        : _selectedKpiFilter == 'listos'
                            ? 'Lotes listos para entrega'
                            : 'Historial de entregas realizadas',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C2826),
                ),
              ),
              if (_selectedKpiFilter == 'entregas') ...[
                DropdownButton<String>(
                  value: _deliveryTimeFilter,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                  underline: const SizedBox(),
                  items: ['Hoy', 'Este Mes', 'Este Año'].map((time) {
                    return DropdownMenuItem(value: time, child: Text(time));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _deliveryTimeFilter = val);
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Contenido según Filtro Seleccionado

          // 1. FILTRO: PUBLICADOS
          if (_selectedKpiFilter == 'publicados') ...[
            publishedProducts.isEmpty
                ? const _EmptyStateTile(message: 'No tienes publicaciones de lotes activas')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: publishedProducts.length,
                    itemBuilder: (context, index) {
                      final product = publishedProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: EcoTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.article_outlined, color: EcoTheme.primary),
                          ),
                          title: Text(
                            product.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${product.batchSize.badgeLabel} • Stock: ${product.batchQuantity} lotes\nContenido: ${product.itemsIncluded}',
                            style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                          ),
                          trailing: Text(
                            product.isDonation ? 'GRATIS' : 'S/ ${product.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: EcoTheme.primary),
                          ),
                        ),
                      );
                    },
                  ),
          ],

          // 2. FILTRO: PENDIENTES (Diseño exacto de imagen)
          if (_selectedKpiFilter == 'pendientes') ...[
            pendingReservations.isEmpty
                ? const _EmptyStateTile(message: 'No hay solicitudes pendientes en este momento')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingReservations.length,
                    itemBuilder: (context, index) {
                      final res = pendingReservations[index];

                      final distance = appState.calculateDistanceText(
                        res.userLocation,
                        res.businessAddress,
                      );

                      return _PendingRequestCard(
                        reservation: res,
                        calculatedDistance: distance,
                        onAccept: () {
                          final success = appState.acceptReservation(res.id);
                          if (success) {
                            _showQrGeneratedDialog(context, res);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo aceptar la reserva. Verifique stock o cupo.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        onReject: () {
                          appState.rejectReservation(res.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Solicitud rechazada.')),
                          );
                        },
                      );
                    },
                  ),
          ],

          // 3. FILTRO: LISTOS (Tocar abre el QR)
          if (_selectedKpiFilter == 'listos') ...[
            confirmedReservations.isEmpty
                ? const _EmptyStateTile(message: 'No hay lotes confirmados pendientes de recojo')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: confirmedReservations.length,
                    itemBuilder: (context, index) {
                      final res = confirmedReservations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () => _showAcceptedQrDetailDialog(context, res, appState),
                          leading: const CircleAvatar(
                            backgroundColor: EcoTheme.primaryLight,
                            child: Icon(Icons.qr_code_2_rounded, color: EcoTheme.primary),
                          ),
                          title: Text(
                            '${res.code} • ${res.userName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${res.batchSize.badgeLabel} • ${res.productTitle}\nTocar para ver Código QR y Validar',
                            style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                          ),
                          trailing: const Icon(Icons.qr_code_scanner_rounded, color: EcoTheme.primary),
                        ),
                      );
                    },
                  ),
          ],

          // 4. FILTRO: ENTREGAS (Historial)
          if (_selectedKpiFilter == 'entregas') ...[
            allDelivered.isEmpty
                ? _EmptyStateTile(message: 'No se encontraron entregas realizadas para el periodo: $_deliveryTimeFilter')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allDelivered.length,
                    itemBuilder: (context, index) {
                      final res = allDelivered[index];
                      final date = res.redeemedAt ?? res.date;
                      final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE1F5FE),
                            child: Icon(Icons.check_circle_rounded, color: Color(0xFF0288D1)),
                          ),
                          title: Text(
                            '${res.productTitle} (${res.batchSize.displayName})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Cliente: ${res.userName} • Entregado: $dateStr',
                            style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'RETIRADO',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ],
      ),
    );
  }

  // Pestaña 2: Peticiones ONGs
  Widget _buildSocialRequestsTab(BuildContext context, AppState appState) {
    if (appState.socialRequests.isEmpty) {
      return const Center(
        child: Text('No hay peticiones de organizaciones sociales por el momento'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appState.socialRequests.length,
      itemBuilder: (context, index) {
        final req = appState.socialRequests[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        req.orgName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: EcoTheme.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: req.urgency == 'Alta' ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Urgencia: ${req.urgency}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: req.urgency == 'Alta' ? Colors.red : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Necesidad: ${req.foodType}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Beneficiarios: ${req.peopleServed} personas • ${req.notes}',
                  style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          appState.updateSocialRequestStatus(req.id, 'En Proceso');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Has contactado a ${req.orgName}')),
                          );
                        },
                        child: const Text('Contactar ONG'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          appState.updateSocialRequestStatus(req.id, 'Atendida');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Donación asignada a ${req.orgName}')),
                          );
                        },
                        child: const Text('Asignar Lote Donado'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Contenedor vació para listas
class _EmptyStateTile extends StatelessWidget {
  final String message;

  const _EmptyStateTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: EcoTheme.textMuted, fontSize: 14),
        ),
      ),
    );
  }
}

// Tarjeta KPI interactiva
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;
  final bool isSelected;

  const _KpiCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? EcoTheme.primary : Colors.transparent,
          width: isSelected ? 2.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? EcoTheme.primary.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2826),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Tarjeta de Solicitud Pendiente
class _PendingRequestCard extends StatelessWidget {
  final Reservation reservation;
  final String calculatedDistance;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingRequestCard({
    required this.reservation,
    required this.calculatedDistance,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isOrg = reservation.userRole == UserRole.socialOrg;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F3E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOrg ? Icons.storefront_outlined : Icons.person_outline_rounded,
              color: const Color(0xFF1B5E20),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2826),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reservation.productTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFF57F17)),
                      SizedBox(width: 4),
                      Text(
                        'Pendiente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'A $calculatedDistance • ${reservation.pickupWindow}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          Column(
            children: [
              SizedBox(
                width: 90,
                height: 36,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 90,
                height: 36,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                    side: const BorderSide(color: Color(0xFF1B5E20), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Rechazar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
