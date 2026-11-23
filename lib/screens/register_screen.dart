import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.localUser;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setUserInfo(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cuenta creada exitosamente como ${_selectedRole.displayName}'),
          backgroundColor: EcoTheme.primary,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Únete a EcoSupply',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EcoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Completa tus datos para empezar a salvar comida y colaborar',
                  style: TextStyle(fontSize: 14, color: EcoTheme.textMuted),
                ),
                const SizedBox(height: 24),

                // Seleccionar Rol
                const Text(
                  'Selecciona tu perfil',
                  style: TextStyle(fontWeight: FontWeight.bold, color: EcoTheme.textDark),
                ),
                const SizedBox(height: 8),
                Column(
                  children: UserRole.values.map((role) {
                    final isSelected = _selectedRole == role;
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
                      child: RadioListTile<UserRole>(
                        value: role,
                        groupValue: _selectedRole,
                        activeColor: EcoTheme.primary,
                        title: Text(
                          role.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          role.description,
                          style: const TextStyle(fontSize: 12, color: EcoTheme.textMuted),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Nombre Completo o de Organización
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _selectedRole == UserRole.business
                        ? 'Nombre del Establecimiento'
                        : _selectedRole == UserRole.socialOrg
                            ? 'Nombre de la Organización / Comedor'
                            : 'Nombre Completo',
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa este campo' : null,
                ),
                const SizedBox(height: 16),

                // Correo Electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
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
                    labelText: 'Teléfono / Celular (Perú +51)',
                    prefixIcon: Icon(Icons.phone_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().length < 9 ? 'Ingresa número de celular de 9 dígitos' : null,
                ),
                const SizedBox(height: 16),

                // Dirección en Perú
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección (Distrito, Lima - Perú)',
                    prefixIcon: Icon(Icons.location_on_outlined, color: EcoTheme.primary),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu dirección' : null,
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: EcoTheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: EcoTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 24),

                // Botón Registrarse
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text('Crear Cuenta'),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          color: EcoTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
