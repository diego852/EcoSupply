import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final bool isRegistrationFlow;

  const RoleSelectionScreen({
    super.key,
    this.isRegistrationFlow = false,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.localUser;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de Tipo de Usuario'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Cómo deseas usar EcoSupply?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: EcoTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona el perfil que mejor describe tu actividad. Puedes probar los diferentes roles en cualquier momento.',
                style: TextStyle(
                  fontSize: 14,
                  color: EcoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Opciones de Roles
              Expanded(
                child: ListView(
                  children: [
                    _RoleOptionCard(
                      role: UserRole.localUser,
                      selectedRole: _selectedRole,
                      icon: Icons.person_outline_rounded,
                      title: 'Usuario Local (Consumidor)',
                      subtitle: 'Explora ofertas de alimentos cerca de ti, reserva a precios de remate en Soles (S/.) y ayuda a reducir desperdicios.',
                      badgeText: 'Ahorro & Calidad',
                      onSelect: () => setState(() => _selectedRole = UserRole.localUser),
                    ),
                    const SizedBox(height: 16),
                    _RoleOptionCard(
                      role: UserRole.business,
                      selectedRole: _selectedRole,
                      icon: Icons.storefront_rounded,
                      title: 'Establecimiento (Comercio)',
                      subtitle: 'Restaurantes, panaderías y supermercados. Publica tus excedentes del día y recupera ingresos evitando pérdidas.',
                      badgeText: 'Ventas & Sostenibilidad',
                      onSelect: () => setState(() => _selectedRole = UserRole.business),
                    ),
                    const SizedBox(height: 16),
                    _RoleOptionCard(
                      role: UserRole.socialOrg,
                      selectedRole: _selectedRole,
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Organización Social (ONG / Comedor)',
                      subtitle: 'Comedores populares y bancos de alimentos. Solicita y gestiona donaciones de alimentos de forma prioritaria.',
                      badgeText: 'Impacto Comunitario',
                      onSelect: () => setState(() => _selectedRole = UserRole.socialOrg),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Botón de Continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    appState.setRole(_selectedRole);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ingresaste como ${_selectedRole.displayName}'),
                        backgroundColor: EcoTheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  child: Text('Ingresar como ${_selectedRole.displayName}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final UserRole role;
  final UserRole selectedRole;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback onSelect;

  const _RoleOptionCard({
    required this.role,
    required this.selectedRole,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = role == selectedRole;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? EcoTheme.primaryLight.withValues(alpha: 0.4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? EcoTheme.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: EcoTheme.primary.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? EcoTheme.primary : EcoTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : EcoTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? EcoTheme.primaryDark : EcoTheme.textDark,
                          ),
                        ),
                      ),
                      Radio<UserRole>(
                        value: role,
                        groupValue: selectedRole,
                        onChanged: (_) => onSelect(),
                        activeColor: EcoTheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? EcoTheme.primary : EcoTheme.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : EcoTheme.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: EcoTheme.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
