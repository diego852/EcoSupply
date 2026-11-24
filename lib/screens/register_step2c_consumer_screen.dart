import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/real_file_picker.dart';
import '../services/url_launcher_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class RegisterStep2cConsumerScreen extends StatefulWidget {
  const RegisterStep2cConsumerScreen({super.key});

  @override
  State<RegisterStep2cConsumerScreen> createState() => _RegisterStep2cConsumerScreenState();
}

class _RegisterStep2cConsumerScreenState extends State<RegisterStep2cConsumerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedDistrict = 'Piura';
  SisfohClassification _selectedSisfoh = SisfohClassification.pobreExtremo;
  bool _obscurePassword = true;
  bool _swornDeclarationChecked = false;
  bool _dataConsentChecked = false;

  final List<PickedRealFile> _pickedRealFiles = [];

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
    _fullNameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Abre el explorador REAL de archivos del sistema (Windows, Android, iOS o Web/Vercel)
  Future<void> _pickFiles(bool isPdfOnly) async {
    final result = await pickRealSystemFiles(
      isPdfOnly: isPdfOnly,
      currentAttachedCount: _pickedRealFiles.length,
      maxFilesAllowed: 3,
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
            content: Text('${result.files.length} constancia(s) adjuntada(s) desde tu sistema.'),
            backgroundColor: EcoTheme.primary,
          ),
        );
      }
    }
  }

  /// Abre directamente la URL externa oficial del SISFOH en una nueva pestaña/navegador
  void _openSisfohPortalDirectly() {
    openExternalSisfohUrl(context);
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Regla 1: DNI único
      final dni = _dniController.text.trim();
      if (appState.isDniAlreadyRegistered(dni)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: El DNI ingresado ya cuenta con un registro activo en EcoSupply.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Regla 2: Correo único
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

      // Regla: Clasificación SISFOH "No pobre" no elegible
      if (_selectedSisfoh == SisfohClassification.noPobre) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este programa de apoyo social está dirigido exclusivamente a hogares en pobreza o pobreza extrema.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar adjunto obligatorio
      if (_pickedRealFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes adjuntar la constancia de Clasificación Socioeconómica (CSE - SISFOH).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar checkboxes
      if (!_swornDeclarationChecked || !_dataConsentChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar la declaración jurada y el tratamiento de datos personales.'),
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
        fullName: _fullNameController.text.trim(),
        email: email,
        phone: _phoneController.text.trim(),
        dni: dni,
        role: UserRole.localUser,
        address: 'Distrito $_selectedDistrict, Piura',
        district: _selectedDistrict,
        status: AccountStatus.pendiente,
        sisfohClassification: _selectedSisfoh,
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
              Text('Registro Enviado para Verificación', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Tu registro como Usuario Local ha sido completado y se encuentra en estado PENDIENTE DE VERIFICACIÓN.\n\nEl administrador revisará tu constancia CSE del SISFOH. Mientras tanto, puedes explorar el catálogo de alimentos.',
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
    final isNotEligible = _selectedSisfoh == SisfohClassification.noPobre;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paso 2C: Registro Consumidor'),
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
                  'Datos del Usuario Local',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa tu información personal para acceder al programa de apoyo social.',
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 20),

                // Nombre Completo
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre y Apellidos completos *',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tus nombres' : null,
                ),
                const SizedBox(height: 16),

                // DNI (8 dígitos exactos)
                TextFormField(
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    labelText: 'DNI (8 dígitos) *',
                    hintText: '71234567',
                    prefixIcon: Icon(Icons.badge_outlined, color: EcoTheme.primary),
                    counterText: '',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length != 8 || int.tryParse(val) == null) {
                      return 'El DNI debe contener exactamente 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Correo electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico *',
                    prefixIcon: Icon(Icons.email_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || !val.contains('@') ? 'Correo no válido' : null,
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular / Teléfono (+51) *',
                    prefixIcon: Icon(Icons.phone_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().length < 9 ? 'Número no válido' : null,
                ),
                const SizedBox(height: 16),

                // Distrito de Piura
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'Distrito de Piura *',
                    prefixIcon: Icon(Icons.map_outlined, color: EcoTheme.primary),
                  ),
                  items: _piuraDistricts.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDistrict = val);
                  },
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

                // SECCIÓN OBLIGATORIA: Verificación socioeconómica (SISFOH)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isNotEligible ? Colors.red.shade50 : EcoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNotEligible ? Colors.red : EcoTheme.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isNotEligible ? Icons.warning_amber_rounded : Icons.verified_rounded,
                            color: isNotEligible ? Colors.red : EcoTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Verificación Socioeconómica (SISFOH)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'EcoSupply es un programa de apoyo social. Para registrarte debes estar clasificado como Pobre o Pobre extremo en el SISFOH.',
                        style: TextStyle(fontSize: 12, color: EcoTheme.textDark, height: 1.35),
                      ),
                      const SizedBox(height: 10),

                      // Botón para consultar directamente en SISFOH externo
                      OutlinedButton.icon(
                        onPressed: _openSisfohPortalDirectly,
                        icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                        label: const Text('Consultar mi clasificación en SISFOH'),
                      ),
                      const SizedBox(height: 12),

                      // Desplegable de Clasificación
                      DropdownButtonFormField<SisfohClassification>(
                        value: _selectedSisfoh,
                        decoration: const InputDecoration(
                          labelText: 'Mi clasificación socioeconómica es *',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: SisfohClassification.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.displayName,
                              style: TextStyle(
                                color: s == SisfohClassification.noPobre ? Colors.red : EcoTheme.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSisfoh = val);
                        },
                      ),

                      if (isNotEligible) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.block, color: Colors.red, size: 18),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Este programa está dirigido exclusivamente a hogares clasificados en pobreza o pobreza extrema.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Adjuntar constancia CSE abriendo explorador de archivos REAL
                      const Text(
                        'Constancia CSE SISFOH (Obligatoria) *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: EcoTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Adjunta imagen o PDF de tu constancia CSE desde tu almacenamiento.',
                        style: TextStyle(fontSize: 11, color: EcoTheme.textMuted),
                      ),
                      const SizedBox(height: 8),

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
                            label: const Text('Adjuntar Imagen', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Lista de archivos seleccionados REALES con vista previa
                      if (_pickedRealFiles.isEmpty)
                        const Text('Ninguna constancia adjuntada.', style: TextStyle(fontSize: 11, color: Colors.red, fontStyle: FontStyle.italic))
                      else
                        Column(
                          children: _pickedRealFiles.map((file) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
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

                // Checkboxes obligatorios
                CheckboxListTile(
                  value: _swornDeclarationChecked,
                  activeColor: EcoTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Declaro que los datos son verdaderos y acepto que la información sea verificada. Entiendo que datos falsos causan la suspensión de mi cuenta. *',
                    style: TextStyle(fontSize: 12, color: EcoTheme.textDark),
                  ),
                  onChanged: (val) => setState(() => _swornDeclarationChecked = val ?? false),
                ),

                CheckboxListTile(
                  value: _dataConsentChecked,
                  activeColor: EcoTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Autorizo el tratamiento de mis datos personales según la Ley N° 29733 (Ley de Protección de Datos Personales). *',
                    style: TextStyle(fontSize: 12, color: EcoTheme.textDark),
                  ),
                  onChanged: (val) => setState(() => _dataConsentChecked = val ?? false),
                ),
                const SizedBox(height: 28),

                // Botón Crear Cuenta
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isNotEligible ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNotEligible ? Colors.grey : EcoTheme.primary,
                    ),
                    child: const Text('Enviar Solicitud de Registro'),
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
