import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(),
              // Logo e Ilustración Visual
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: EcoTheme.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: EcoTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 90,
                  color: EcoTheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              // Título y Eslogan
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: EcoTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: 'Eco'),
                    TextSpan(
                      text: 'Supply',
                      style: TextStyle(color: EcoTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rescata alimentos de calidad, ahorra en Soles y apoya el impacto social en tu comunidad.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: EcoTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              // Beneficios rápidos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: EcoTheme.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EcoTheme.primaryLight),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BenefitItem(
                      icon: Icons.savings_outlined,
                      label: 'Precios Bajos',
                    ),
                    _BenefitItem(
                      icon: Icons.storefront_outlined,
                      label: 'Comercios Locales',
                    ),
                    _BenefitItem(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Donaciones ONG',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Botones de Acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Crear Cuenta'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Explorar tipos de usuario',
                      style: TextStyle(
                        color: EcoTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: EcoTheme.primary),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: EcoTheme.primary, size: 26),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: EcoTheme.textDark,
          ),
        ),
      ],
    );
  }
}
