import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'carlos.mendoza@email.com');
  final _passwordController = TextEditingController(text: '123456');
  UserRole _selectedRole = UserRole.localUser;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setUserInfo(
        name: _emailController.text.contains('@')
            ? _emailController.text.split('@').first
            : _emailController.text,
        email: _emailController.text,
        role: _selectedRole,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenido a EcoSupply (${_selectedRole.displayName})'),
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
        title: const Text('Inicio de Sesión'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: EcoTheme.primaryLight,
                    child: Icon(Icons.eco_rounded, color: EcoTheme.primary, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '¡Hola de nuevo!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: EcoTheme.textDark,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Ingresa a tu cuenta para continuar reduciendo el desperdicio',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: EcoTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 28),

                // Selector de Rol rápido
                const Text(
                  'Tipo de Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, color: EcoTheme.textDark),
                ),
                const SizedBox(height: 8),
                Row(
                  children: UserRole.values.map((role) {
                    final isSelected = _selectedRole == role;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = role),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? EcoTheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? EcoTheme.primary : const Color(0xFFD1D5DB),
                            ),
                          ),
                          child: Text(
                            role.shortTag,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : EcoTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Correo Electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined, color: EcoTheme.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu correo electrónico';
                    }
                    return null;
                  },
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
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de recuperación enviada a tu correo de prueba.'),
                        ),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Ingresar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Aún no tienes una cuenta? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Regístrate aquí',
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
