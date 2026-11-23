import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  String _searchQuery = '';
  String _selectedCategory = 'Todo';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todo', 'icon': Icons.grid_view_rounded},
    {'name': 'Panadería', 'icon': Icons.breakfast_dining_outlined},
    {'name': 'Menús', 'icon': Icons.restaurant_outlined},
    {'name': 'Café', 'icon': Icons.coffee_outlined},
    {'name': 'Frutas', 'icon': Icons.apple_outlined},
    {'name': 'Donación', 'icon': Icons.favorite_border_rounded},
  ];

  void _handleDonationProductTap(BuildContext context, Product product, AppState appState) {
    if (product.isDonation && !product.isSmallBatchDonation && appState.currentRole == UserRole.localUser) {
      // Bloquear consumidor si es lote grande
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.volunteer_activism_rounded, color: EcoTheme.primary, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Donación para ONGs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Los consumidores locales solo pueden reservar donaciones en lotes pequeños.\n\n"${product.title}" es un lote grande destinado exclusivamente a comedores populares y bancos de alimentos.',
                style: const TextStyle(fontSize: 14, color: EcoTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EcoTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: EcoTheme.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pista: Puedes cambiar a perfil ONG desde la pestaña "Perfil".',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: EcoTheme.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.setRole(UserRole.socialOrg);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Modo cambiado a Organización Social (ONG)'),
                    backgroundColor: EcoTheme.primary,
                  ),
                );
              },
              child: const Text('Cambiar a perfil ONG'),
            ),
          ],
        ),
      );
    } else {
      // Permitir ver detalle y reservar
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final query = _searchQuery.toLowerCase().trim();

    // Separación y filtrado de Ofertas de Pago y Donaciones
    final paidProducts = appState.products.where((p) {
      if (p.isDonation) return false;
      final matchesCategory = _selectedCategory == 'Todo' || p.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.businessName.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    final donationProducts = appState.products.where((p) {
      if (!p.isDonation) return false;
      final matchesCategory = _selectedCategory == 'Todo' || _selectedCategory == 'Donación' || p.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.businessName.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera con Logo "EcoSupply" y Subtítulo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          color: EcoTheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EcoSupply',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B5E20),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Buena comida, un mejor mañana',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, size: 26, color: Color(0xFF1C2826)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, size: 26, color: Color(0xFF1C2826)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Barra de Búsqueda y Ubicación "Pill Shape"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3E9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF1C2826), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Buscar panes, menús, frutas',
                            hintStyle: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: Colors.grey.shade400,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Color(0xFF1B5E20), size: 20),
                          const SizedBox(width: 4),
                          const Text(
                            'Miraflores, Lima',
                            style: TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1B5E20), size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Fila de Filtros de Categoría
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat['name'] == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['name']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF1C2826),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF1C2826),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 4. Tarjetas de Ofertas de Pago (Scroll Horizontal)
              if (paidProducts.isNotEmpty) ...[
                SizedBox(
                  height: 285,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: paidProducts.length,
                    itemBuilder: (context, index) {
                      final product = paidProducts[index];
                      return _PaidProductCard(
                        product: product,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 5. Sección de Donaciones Disponibles
              if (donationProducts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Donaciones disponibles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2826),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = 'Donación');
                        },
                        child: const Row(
                          children: [
                            Text(
                              'Ver todas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: EcoTheme.primary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 18, color: EcoTheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Lista Vertical de Donaciones
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: donationProducts.length,
                  itemBuilder: (context, index) {
                    final product = donationProducts[index];
                    return _DonationItemTile(
                      product: product,
                      onTap: () => _handleDonationProductTap(context, product, appState),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta de Oferta de Pago (Horizontal)
class _PaidProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _PaidProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discountPercent = product.originalPrice > 0
        ? (((product.originalPrice - product.discountedPrice) / product.originalPrice) * 100).round()
        : 0;

    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con Insignia y Botón de Corazón
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  product.imageUrl,
                  height: 125,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 125,
                    color: EcoTheme.primaryLight,
                    child: const Icon(Icons.fastfood, color: EcoTheme.primary, size: 40),
                  ),
                ),
              ),
              // Insignia Descuento
              if (discountPercent > 0)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB8C00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-$discountPercent %',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Corazón Favorito
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 18,
                    color: Color(0xFF1C2826),
                  ),
                ),
              ),
            ],
          ),

          // Info de la oferta
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2826),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Precios
                Row(
                  children: [
                    Text(
                      'S/ ${product.discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'S/ ${product.originalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Establecimiento + Distancia
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${product.businessName} • ${product.distanceText}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Horario de recojo
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        product.expiryText,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Botón Reservar
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Fila de Item de Donación (Vertical)
class _DonationItemTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _DonationItemTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imageUrl,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 75,
                height: 75,
                color: EcoTheme.primaryLight,
                child: const Icon(Icons.volunteer_activism, color: EcoTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C2826),
                          ),
                          children: [
                            TextSpan(text: product.title),
                            const TextSpan(
                              text: ' • Gratis',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${product.businessName} • ${product.distanceText}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        product.expiryText,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Badge de tipo de lote
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: product.isSmallBatchDonation ? EcoTheme.primaryLight : const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.isSmallBatchDonation ? 'Lote pequeño (Consumidores y ONG)' : 'Lote grande (Exclusivo ONG)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: product.isSmallBatchDonation ? EcoTheme.primaryDark : Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Botón "Ver producto" estilo Pill Menta
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Ver producto',
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
