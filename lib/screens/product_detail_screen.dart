import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'reservation_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  void _tryReserveBatch(BuildContext context, AppState appState) {
    final errorMessage = appState.validateReservation(
      product: product,
      userRole: appState.currentRole,
      userEmail: appState.userEmail,
    );

    if (errorMessage != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.block_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text('Reserva no permitida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 14, color: EcoTheme.textDark, height: 1.4),
              ),
              const SizedBox(height: 16),
              if (appState.hasUsedMonthlyQuota(appState.userEmail) && appState.currentRole == UserRole.localUser) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EcoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: EcoTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Próximo cupo disponible: 1/${appState.getNextQuotaAvailableDate().month}/${appState.getNextQuotaAvailableDate().year}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationScreen(product: product),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: EcoTheme.primaryLight,
                      child: const Center(
                        child: Icon(Icons.inventory_2_rounded, size: 80, color: EcoTheme.primary),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Badge del tamaño de lote
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.batchSize == BatchSize.small
                            ? EcoTheme.primary
                            : Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.batchSize.badgeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y Modalidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: EcoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: EcoTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isDonation ? Colors.purple.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: product.isDonation ? Colors.purple : Colors.orange,
                          ),
                        ),
                        child: Text(
                          product.modality.displayName,
                          style: TextStyle(
                            color: product.isDonation ? Colors.purple : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Título del Lote
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: EcoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alimentos Incluidos en el Lote Completo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: EcoTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, color: EcoTheme.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Contenido del Lote Completo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: EcoTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.itemsIncluded,
                          style: const TextStyle(
                            fontSize: 14,
                            color: EcoTheme.textDark,
                            height: 1.4,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: EcoTheme.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              'Cantidad estimada: ${product.totalItemsCount} unidades (Informativo)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: EcoTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Establecimiento
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
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
                                product.businessName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: EcoTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.businessAddress} • ${product.distanceText}',
                                style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horario de Límite y Recojo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EcoTheme.orangeWarning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: EcoTheme.orangeWarning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: EcoTheme.orangeWarning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Horario de Recojo del Lote',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: EcoTheme.orangeWarning,
                                ),
                              ),
                              Text(
                                '${product.expiryText} (${product.pickupSchedule})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: EcoTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stock de Lotes
                  Row(
                    children: [
                      const Icon(Icons.all_inbox_rounded, size: 18, color: EcoTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Lotes completos disponibles: ${product.batchQuantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: product.batchQuantity > 0 ? EcoTheme.textDark : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barra Inferior de Confirmación
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Precio por Lote Completo',
                    style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                  ),
                  if (product.isDonation)
                    const Text(
                      'DONACIÓN GRATIS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        Text(
                          'S/ ${product.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: EcoTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'S/ ${product.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: EcoTheme.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  onPressed: product.batchQuantity > 0
                      ? () => _tryReserveBatch(context, appState)
                      : null,
                  child: Text(
                    product.batchQuantity > 0 ? 'Reservar Lote Completo' : 'Agotado',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
