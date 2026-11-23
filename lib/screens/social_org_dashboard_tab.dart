import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

class SocialOrgDashboardTab extends StatelessWidget {
  const SocialOrgDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final donationBatches = appState.products.where((p) => p.isDonation).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Social: ${appState.orgName}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EcoTheme.primary, EcoTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impacto Alimentario Acumulado',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _OrgMetricItem(value: '1,240', label: 'Raciones Servidas'),
                        _OrgMetricItem(value: '380', label: 'Familias Apoyadas'),
                        _OrgMetricItem(value: '12', label: 'Comercios Aliados'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lotes de Donación Disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EcoTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: EcoTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${donationBatches.length} lotes',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: EcoTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              donationBatches.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay lotes de donaciones gratuitas activas en este instante.',
                          style: TextStyle(color: EcoTheme.textMuted),
                        ),
                      ),
                    )
                  : Column(
                      children: donationBatches.map((product) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: EcoTheme.primaryLight,
                              child: Icon(Icons.volunteer_activism, color: EcoTheme.primary),
                            ),
                            title: Text(
                              product.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${product.batchSize.badgeLabel} • ${product.businessName}\nContenido: ${product.itemsIncluded}',
                              style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                            ),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              child: const Text('Solicitar Lote', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 24),
              const Text(
                'Nuestras Alianzas Locales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EcoTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const _PartnerTile(
                name: 'Panadería Don Lucho',
                type: 'Donante frecuente de lotes de panadería',
                address: 'Miraflores, Lima',
              ),
              const SizedBox(height: 8),
              const _PartnerTile(
                name: 'Café Tallán',
                type: 'Donante de lotes grandes de menús criollos',
                address: 'Miraflores, Lima',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgMetricItem extends StatelessWidget {
  final String value;
  final String label;

  const _OrgMetricItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class _PartnerTile extends StatelessWidget {
  final String name;
  final String type;
  final String address;

  const _PartnerTile({
    required this.name,
    required this.type,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.handshake_outlined, color: EcoTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '$type • $address',
                  style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
