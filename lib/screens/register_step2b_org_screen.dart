import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/real_file_picker.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class RegisterStep2bOrgScreen extends StatefulWidget {
  const RegisterStep2bOrgScreen({super.key});

  @override
  State<RegisterStep2bOrgScreen> createState() => _RegisterStep2bOrgScreenState();
}

class _RegisterStep2bOrgScreenState extends State<RegisterStep2bOrgScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedOrgType = 'Comedor Popular';
  String _selectedDistrict = 'Piura';
  bool _obscurePassword = true;

  // Lista de archivos reales seleccionados del sistema (hasta 3)
  final List<PickedRealFile> _pickedRealFiles = [];

  final List<String> _orgTypes = [
    'Comedor Popular',
    'Olla Común',
    'ONG Social',
    'Parroquia / Iglesia',
    'Otra organización comunitaria',
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
    _orgNameController.dispose();
    _addressController.dispose();
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
            content: Text('${result.files.length} archivo(s) adjuntado(s) desde tu sistema.'),
            backgroundColor: EcoTheme.primary,
          ),
        );
      }
    }
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      if (_pickedRealFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes adjuntar al menos 1 documento de acreditación desde tu sistema.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final appState = Provider.of<AppState>(context, listen: false);

      // Convertir archivos reales seleccionados a DocumentAttachment para el modelo del perfil
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
        fullName: _orgNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: UserRole.socialOrg,
        orgType: _selectedOrgType,
        address: _addressController.text.trim(),
        district: _selectedDistrict,
        status: AccountStatus.pendiente,
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
              Text('Registro Enviado', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Tu solicitud de registro para Organización Social ha sido recibida con éxito.\n\nRevisaremos tus documentos en un plazo máximo de 48 horas. Te notificaremos cuando tu cuenta sea aprobada.',
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
        title: const Text('Paso 2B: Registro Organización'),
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
                  'Datos de la Organización Social',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Registra tu comedor popular, olla común u ONG para solicitar donaciones gratuitas.',
                  style: TextStyle(fontSize: 13, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _orgNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la organización o comedor *',
                    prefixIcon: Icon(Icons.volunteer_activism_rounded, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedOrgType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de organización *',
                    prefixIcon: Icon(Icons.apartment_rounded, color: EcoTheme.primary),
                  ),
                  items: _orgTypes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedOrgType = val);
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección o ubicación del local *',
                    prefixIcon: Icon(Icons.location_on_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la dirección' : null,
                ),
                const SizedBox(height: 16),

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

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono / Celular de contacto *',
                    prefixIcon: Icon(Icons.phone_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().length < 9 ? 'Número no válido' : null,
                ),
                const SizedBox(height: 16),

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

                // SECCIÓN OBLIGATORIA: Documentos de Acreditación
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
                          Icon(Icons.upload_file_rounded, color: EcoTheme.primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Documentos de Acreditación (Obligatorio) *',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EcoTheme.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Adjunta resolución municipal, registro de comedor/olla común, partida SUNARP o ficha RUC. (Hasta 3 archivos, máx 5 MB c/u, JPG/PNG/PDF).',
                        style: TextStyle(fontSize: 12, color: EcoTheme.textDark),
                      ),
                      const SizedBox(height: 12),

                      // Botones para abrir el selector REAL del sistema
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
                      const SizedBox(height: 12),

                      // Lista de archivos seleccionados REALES con vista previa y botón quitar
                      if (_pickedRealFiles.isEmpty)
                        const Text(
                          'Ningún archivo seleccionado todavía.',
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
                                  // Vista Previa de Imagen o Icono PDF
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
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRegistration,
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
