import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class PublishProductScreen extends StatefulWidget {
  const PublishProductScreen({super.key});

  @override
  State<PublishProductScreen> createState() => _PublishProductScreenState();
}

class _PublishProductScreenState extends State<PublishProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _itemsIncludedController = TextEditingController();
  final _totalItemsCountController = TextEditingController(text: '8');
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _batchQuantityController = TextEditingController(text: '2');
  final _expiryTextController = TextEditingController(text: 'Hoy hasta las 8:00 PM');
  final _pickupScheduleController = TextEditingController(text: '5:00 PM - 8:00 PM');

  BatchSize _selectedBatchSize = BatchSize.small;
  Modality _selectedModality = Modality.socialSale;
  String _selectedCategory = 'Panadería';

  final List<String> _categories = [
    'Panadería',
    'Frutas y Verduras',
    'Restaurantes',
    'Lácteos',
    'Platos Preparados',
    'Menús',
    'Café',
    'Donaciones',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _itemsIncludedController.dispose();
    _totalItemsCountController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _batchQuantityController.dispose();
    _expiryTextController.dispose();
    _pickupScheduleController.dispose();
    super.dispose();
  }

  void _publishBatchProduct() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      final originalPrice = double.tryParse(_originalPriceController.text) ?? 0.0;
      final discountedPrice = _selectedModality == Modality.freeDonation
          ? 0.0
          : (double.tryParse(_discountedPriceController.text) ?? 0.0);
      final batchQuantity = int.tryParse(_batchQuantityController.text) ?? 1;
      final totalItemsCount = int.tryParse(_totalItemsCountController.text) ?? 1;

      final newProduct = Product(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        itemsIncluded: _itemsIncludedController.text.trim(),
        totalItemsCount: totalItemsCount,
        batchSize: _selectedBatchSize,
        modality: _selectedModality,
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        batchQuantity: batchQuantity,
        category: _selectedCategory,
        businessName: appState.businessName,
        businessAddress: 'Av. Larco 456, Miraflores, Lima',
        expiryText: _expiryTextController.text.trim(),
        pickupSchedule: _pickupScheduleController.text.trim(),
        distanceText: '0.8 km',
        imageUrl: _selectedModality == Modality.freeDonation
            ? 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400'
            : 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      );

      appState.addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Lote "${newProduct.title}" publicado exitosamente!'),
          backgroundColor: EcoTheme.primary,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Lote de Alimentos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Publicación por Lote Completo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Todos los alimentos en EcoSupply se ofrecen en lotes cerrados. Los usuarios reservarán el lote completo.',
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Campo Obligatorio: TAMAÑO DEL LOTE
                const Text(
                  'Tamaño del Lote (Obligatorio) *',
                  style: TextStyle(fontWeight: FontWeight.bold, color: EcoTheme.textDark, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Column(
                  children: BatchSize.values.map((size) {
                    final isSelected = _selectedBatchSize == size;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? EcoTheme.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? EcoTheme.primary : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: RadioListTile<BatchSize>(
                        value: size,
                        groupValue: _selectedBatchSize,
                        activeColor: EcoTheme.primary,
                        title: Text(
                          size.badgeLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          size.description,
                          style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedBatchSize = val);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Modalidad: Venta Social o Donación Gratuita
                const Text(
                  'Modalidad *',
                  style: TextStyle(fontWeight: FontWeight.bold, color: EcoTheme.textDark, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Row(
                  children: Modality.values.map((m) {
                    final isSel = _selectedModality == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedModality = m),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? EcoTheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? EcoTheme.primary : const Color(0xFFD1D5DB),
                            ),
                          ),
                          child: Text(
                            m.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : EcoTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Título del Lote
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título de la Publicación',
                    hintText: 'Ej. Lote Pequeño: Panes y Repostería del Día',
                    prefixIcon: Icon(Icons.inventory_2_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 16),

                // Alimentos incluidos en el lote
                TextFormField(
                  controller: _itemsIncludedController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alimentos que incluye el lote *',
                    hintText: 'Ej. 4 baguettes de masa madre, 3 ciabattas, 2 croissants frescos',
                    prefixIcon: Icon(Icons.list_alt_rounded, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Especifica qué alimentos contiene' : null,
                ),
                const SizedBox(height: 16),

                // Cantidad Informativa de Productos y Stock de Lotes
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalItemsCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cant. Items (Informativo)',
                          hintText: '8',
                          prefixIcon: Icon(Icons.numbers_rounded, color: EcoTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _batchQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock de Lotes Completo',
                          hintText: '2',
                          prefixIcon: Icon(Icons.all_inbox_rounded, color: EcoTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categoría
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría de Alimentos',
                    prefixIcon: Icon(Icons.category_outlined, color: EcoTheme.primary),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                // Precios del Lote Completo (S/.)
                if (_selectedModality == Modality.socialSale) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _originalPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Precio Original Lote (S/.)',
                            hintText: '25.00',
                            prefixIcon: Icon(Icons.money_off_rounded, color: EcoTheme.primary),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _discountedPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Precio Social Lote (S/.)',
                            hintText: '8.00',
                            prefixIcon: Icon(Icons.attach_money_rounded, color: EcoTheme.primary),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Tiempos Límite y Horarios
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryTextController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha/Hora Límite',
                          hintText: 'Hoy 8:00 PM',
                          prefixIcon: Icon(Icons.timer_outlined, color: EcoTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _pickupScheduleController,
                        decoration: const InputDecoration(
                          labelText: 'Horario Recojo',
                          hintText: '5:00 PM - 8:00 PM',
                          prefixIcon: Icon(Icons.schedule_rounded, color: EcoTheme.primary),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Botón de Publicar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _publishBatchProduct,
                    child: const Text('Publicar Lote Completo en EcoSupply'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
