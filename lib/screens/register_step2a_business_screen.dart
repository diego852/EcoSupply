import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_models.dart';
import '../services/nominatim_geocoding_service.dart';
import '../services/real_file_picker.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'map_location_picker_screen.dart';
import 'welcome_screen.dart';

class RegisterStep2aBusinessScreen extends StatefulWidget {
  const RegisterStep2aBusinessScreen({super.key});

  @override
  State<RegisterStep2aBusinessScreen> createState() => _RegisterStep2aBusinessScreenState();
}

class _RegisterStep2aBusinessScreenState extends State<RegisterStep2aBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _rucController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _departmentController = TextEditingController(text: 'Piura');
  final _provinceController = TextEditingController(text: 'Piura');
  final _districtController = TextEditingController(text: 'Piura');

  String _selectedType = 'Restaurante';
  String _selectedDistrict = 'Piura';
  bool _obscurePassword = true;
  bool _swornDeclarationChecked = false;
  bool _isAddressEditable = false;

  // Ubicación Geográfica (Latitud y Longitud)
  double? _selectedLat;
  double? _selectedLng;

  // Archivos adjuntos reales
  final List<PickedRealFile> _pickedRealFiles = [];

  final List<String> _businessTypes = [
    'Restaurante',
    'Panadería',
    'Pastelería',
    'Cafetería',
    'Tienda / Bodega',
    'Supermercado / Minimarket',
    'Comida procesada',
    'Otro comercio',
  ];

  final List<String> _piuraDistricts = [
    'Piura',
    'Castilla',
    'Veintiséis de Octubre',
    'Catacaos',
    'Cura Mori',
    'El Tallán',
    'La Arena',
    'La Unión',
    'Las Lomas',
    'Tambo Grande',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _rucController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  /// Abre la pantalla del mapa interactivo
  Future<void> _openMapPicker() async {
    final LatLng? initial = (_selectedLat != null && _selectedLng != null)
        ? LatLng(_selectedLat!, _selectedLng!)
        : null;

    final NominatimGeocodingResult? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(initialLocation: initial),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLat = result.latitude;
        _selectedLng = result.longitude;

        if (result.isSuccess) {
          _departmentController.text = result.department;
          _provinceController.text = result.province;
          _addressController.text = result.address;

          // Intentar emparejar el distrito resultante con la lista de Piura
          final matchedDistrict = _piuraDistricts.firstWhere(
            (d) => d.toLowerCase() == result.district.toLowerCase(),
            orElse: () => _selectedDistrict,
          );
          _selectedDistrict = matchedDistrict;
          _districtController.text = matchedDistrict;
        } else {
          _isAddressEditable = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'No pudimos obtener la dirección, complétala manualmente.'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
      });
    }
  }

  /// Abre el explorador REAL de archivos del sistema
  Future<void> _pickFiles(bool isPdfOnly) async {
    final result = await pickRealSystemFiles(
      isPdfOnly: isPdfOnly,
      currentAttachedCount: _pickedRealFiles.length,
      maxFilesAllowed: 6,
      maxSizeBytes: 5 * 1024 * 1024, // 5 MB
    );

    if (result.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (result.files.isNotEmpty) {
      setState(() {
        _pickedRealFiles.addAll(result.files);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} documento(s) adjuntado(s) desde tu sistema.'),
            backgroundColor: EcoTheme.primary,
          ),
        );
      }
    }
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Regla de Negocio: RUC único
      final ruc = _rucController.text.trim();
      if (appState.isRucAlreadyRegistered(ruc)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: El RUC ingresado ya se encuentra registrado en EcoSupply.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Regla de Negocio: Correo único
      final email = _emailController.text.trim();
      if (appState.isEmailAlreadyRegistered(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: El correo electrónico ya está registrado en el sistema.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar que se hayan subido documentos de acreditación del local
      if (_pickedRealFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes adjuntar al menos los documentos obligatorios de verificación del local.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar Declaración Jurada
      if (!_swornDeclarationChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes declarar que el local existe y opera legalmente.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final attachments = _pickedRealFiles.map((file) {
        return DocumentAttachment(
          id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
          fileName: file.name,
          fileType: file.isPdf ? 'application/pdf' : 'image/${file.extension}',
          fileSizeMb: file.sizeMb,
          uploadDate: DateTime.now(),
        );
      }).toList();

      final newProfile = UserProfile(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _businessNameController.text.trim(),
        email: email,
        phone: _phoneController.text.trim(),
        ruc: ruc,
        role: UserRole.business,
        businessType: _selectedType,
        department: _departmentController.text.trim(),
        province: _provinceController.text.trim(),
        district: _selectedDistrict,
        address: _addressController.text.trim(),
        latitude: _selectedLat,
        longitude: _selectedLng,
        status: AccountStatus.pendiente, // Estado inicial 'pendiente'
        attachedDocuments: attachments,
      );

      appState.registerUserAccount(newProfile);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Column(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: 60),
              SizedBox(height: 10),
              Text('Registro Enviado a Verificación', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Tu solicitud de registro para Establecimiento ha sido enviada con éxito.\n\nRevisaremos tus documentos y la ubicación de tu local en un plazo máximo de 48 horas. Te avisaremos por correo cuando tu cuenta sea aprobada.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: EcoTheme.textDark),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paso 2A: Registro Establecimiento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos del Establecimiento',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa la información comercial y la ubicación de tu local en Piura.',
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Nombre comercial
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre comercial del establecimiento *',
                    prefixIcon: Icon(Icons.storefront_rounded, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre comercial' : null,
                ),
                const SizedBox(height: 16),

                // Tipo de establecimiento
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de establecimiento *',
                    prefixIcon: Icon(Icons.category_outlined, color: EcoTheme.primary),
                  ),
                  items: _businessTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),

                // RUC (Obligatorio: 11 dígitos iniciando en 10 o 20)
                TextFormField(
                  controller: _rucController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  decoration: const InputDecoration(
                    labelText: 'RUC (11 dígitos, inicia en 10 o 20) *',
                    hintText: '20123456789',
                    prefixIcon: Icon(Icons.badge_outlined, color: EcoTheme.primary),
                    counterText: '',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length != 11) {
                      return 'El RUC debe tener exactamente 11 dígitos';
                    }
                    if (!RegExp(r'^(10|20)\d{9}$').hasMatch(val.trim())) {
                      return 'RUC no válido. Debe comenzar con 10 o 20';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // SECCIÓN 1: Ubicación con Mapa y Autorrelleno
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EcoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: EcoTheme.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.map_rounded, color: EcoTheme.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Ubicación del Local en Mapa (Piura)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.primaryDark),
                            ),
                          ),
                          IconButton(
                            icon: Icon(_isAddressEditable ? Icons.lock_open : Icons.edit, size: 20, color: EcoTheme.primary),
                            tooltip: 'Habilitar edición manual',
                            onPressed: () {
                              setState(() => _isAddressEditable = !_isAddressEditable);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Selecciona el punto exacto en el mapa para autorrellenar los datos de ubicación.',
                        style: TextStyle(fontSize: 12, color: EcoTheme.textDark),
                      ),
                      const SizedBox(height: 12),

                      // Botón para seleccionar ubicación en mapa
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openMapPicker,
                          icon: const Icon(Icons.pin_drop_rounded),
                          label: Text(_selectedLat != null
                              ? 'Cambiar Ubicación en Mapa'
                              : 'Seleccionar ubicación en el mapa'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Vista previa pequeña del mapa si hay ubicación seleccionada
                      if (_selectedLat != null && _selectedLng != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 140,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(_selectedLat!, _selectedLng!),
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.untitled',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(_selectedLat!, _selectedLng!),
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Campos de Autorrelleno (Lectura inicial, editables si falla el mapa)
                      TextFormField(
                        controller: _departmentController,
                        readOnly: !_isAddressEditable,
                        decoration: const InputDecoration(
                          labelText: 'Departamento *',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _provinceController,
                        readOnly: !_isAddressEditable,
                        decoration: const InputDecoration(
                          labelText: 'Provincia *',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: const InputDecoration(
                          labelText: 'Distrito *',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: _piuraDistricts.map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDistrict = val;
                              _districtController.text = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _addressController,
                        readOnly: !_isAddressEditable,
                        decoration: const InputDecoration(
                          labelText: 'Dirección del Local *',
                          hintText: 'Ej. Av. Grau 450',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la dirección' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Correo electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico institucional *',
                    prefixIcon: Icon(Icons.email_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || !val.contains('@') ? 'Correo no válido' : null,
                ),
                const SizedBox(height: 16),

                // Teléfono (+51)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono / Celular (Perú +51) *',
                    hintText: '987654321',
                    prefixIcon: Icon(Icons.phone_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().length < 9 ? 'Número no válido' : null,
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña (Mínimo 6 caracteres) *',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: EcoTheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: EcoTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 24),

                // SECCIÓN 2: Documentos de Verificación del Local
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EcoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: EcoTheme.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: EcoTheme.primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verificación del Establecimiento (Obligatorio) *',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Para proteger a la comunidad, validamos que tu local exista y esté en funcionamiento.\n\nObligatorios: Licencia municipal, Ficha RUC (Activo/Habido) y Foto de la Fachada.',
                        style: TextStyle(fontSize: 12, color: EcoTheme.textDark, height: 1.35),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _pickFiles(true),
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                            label: const Text('Adjuntar PDF', style: TextStyle(fontSize: 12)),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _pickFiles(false),
                            icon: const Icon(Icons.image_rounded, size: 16),
                            label: const Text('Adjuntar Imagen Fachada', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_pickedRealFiles.isEmpty)
                        const Text(
                          'Ningún documento adjuntado todavía.',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.red),
                        )
                      else
                        Column(
                          children: _pickedRealFiles.map((file) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: file.isImage && file.bytes != null
                                        ? Image.memory(
                                            file.bytes!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 40,
                                            height: 40,
                                            color: EcoTheme.primaryLight,
                                            child: Icon(
                                              file.isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                                              color: EcoTheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.name,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${file.sizeMb.toStringAsFixed(2)} MB • ${file.extension.toUpperCase()}',
                                          style: const TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 20, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _pickedRealFiles.removeWhere((f) => f.name == file.name && f.size == file.size);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Checkbox Declaración Jurada
                CheckboxListTile(
                  value: _swornDeclarationChecked,
                  activeColor: EcoTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Declaro que el local existe, opera legalmente y que la información y documentos son verdaderos. *',
                    style: TextStyle(fontSize: 12, color: EcoTheme.textDark),
                  ),
                  onChanged: (val) => setState(() => _swornDeclarationChecked = val ?? false),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRegistration,
                    child: const Text('Enviar Solicitud de Registro de Comercio'),
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
