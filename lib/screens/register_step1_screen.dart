import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'register_step2a_business_screen.dart';
import 'register_step2b_org_screen.dart';
import 'register_step2c_consumer_screen.dart';

class RegisterStep1Screen extends StatelessWidget {
  const RegisterStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paso 1: Tipo de Usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Cómo quieres usar EcoSupply?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: EcoTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona el perfil que se adapta a ti para ingresar los datos correspondientes.',
                style: TextStyle(
                  fontSize: 14,
                  color: EcoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _UserTypeCard(
                      icon: Icons.storefront_rounded,
                      title: 'Establecimiento',
                      subtitle: 'Restaurante, panadería, cafetería, pastelería, tienda u otro comercio. Publica tus excedentes y recupera ingresos.',
                      badge: 'Comercio / Tienda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterStep2aBusinessScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _UserTypeCard(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'Organización Social',
                      subtitle: 'Comedor popular, olla común, ONG u organización comunitaria. Solicita donaciones gratuitas de alimentos.',
                      badge: 'ONG / Comedor Popular',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterStep2bOrgScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _UserTypeCard(
                      icon: Icons.person_rounded,
                      title: 'Usuario Local (Consumidor)',
                      subtitle: 'Persona clasificada en el SISFOH (Pobre / Pobre extremo) que desea comprar alimentos de calidad a precio social.',
                      badge: 'Apoyo Social SISFOH',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterStep2cConsumerScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: EcoTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: EcoTheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: EcoTheme.textDark,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: EcoTheme.primary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoTheme.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: EcoTheme.primaryDark,
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
      ),
    );
  }
}
