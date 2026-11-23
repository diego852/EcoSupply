import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'publish_product_screen.dart';

class BusinessDashboardTab extends StatelessWidget {
  const BusinessDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final businessProducts = appState.products.where((p) => p.businessName == appState.businessName || p.businessName.contains('Don Lucho')).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel: ${appState.businessName}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Lotes Vendidos y Donados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EcoTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.monetization_on_outlined,
                      title: 'Venta Social Hoy',
                      value: 'S/ 126.00',
                      color: EcoTheme.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.all_inbox_rounded,
                      title: 'Lotes Rescatados',
                      value: '14 lotes',
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'Donaciones ONGs',
                      value: '4 lotes',
                      color: EcoTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PublishProductScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  label: const Text('Publicar Nuevo Lote Completo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tus Lotes Publicados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EcoTheme.textDark,
                    ),
                  ),
                  Text(
                    '${businessProducts.length} activos',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: EcoTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              businessProducts.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Center(
                        child: Text('No hay publicaciones de lotes activas hoy'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: businessProducts.length,
                      itemBuilder: (context, index) {
                        final product = businessProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
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
                                        product.batchSize.badgeLabel,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                                      ),
                                    ),
                                    Text(
                                      'Stock: ${product.batchQuantity} lotes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: product.batchQuantity > 0 ? EcoTheme.primary : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Incluye: ${product.itemsIncluded}',
                                  style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  product.isDonation
                                      ? 'Modalidad: Donación Gratuita'
                                      : 'Precio Social: S/ ${product.discountedPrice.toStringAsFixed(2)} (Original S/ ${product.originalPrice.toStringAsFixed(2)})',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: EcoTheme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
