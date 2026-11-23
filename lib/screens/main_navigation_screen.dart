import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'business_dashboard_tab.dart';
import 'catalog_tab.dart';
import 'my_reservations_tab.dart';
import 'profile_screen.dart';
import 'publish_product_screen.dart';
import 'received_requests_tab.dart';
import 'social_org_dashboard_tab.dart';
import 'social_requests_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final role = appState.currentRole;

    List<Widget> screens;
    List<BottomNavigationBarItem> items;

    switch (role) {
      case UserRole.localUser:
        screens = const [
          CatalogTab(),
          MyReservationsTab(),
          SocialOrgDashboardTab(),
          ProfileScreen(),
        ];
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront_rounded),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Mis Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism_rounded),
            label: 'Impacto ONG',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ];
        break;

      case UserRole.business:
        screens = const [
          BusinessDashboardTab(),
          PublishProductScreen(),
          ReceivedRequestsTab(),
          ProfileScreen(),
        ];
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Mi Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox_rounded),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ];
        break;

      case UserRole.socialOrg:
        screens = const [
          SocialOrgDashboardTab(),
          SocialRequestsTab(),
          CatalogTab(),
          ProfileScreen(),
        ];
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism_rounded),
            label: 'Panel Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check_rounded),
            activeIcon: Icon(Icons.playlist_add_check_circle_rounded),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            activeIcon: Icon(Icons.fastfood_rounded),
            label: 'Donaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ];
        break;
    }

    final validIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: screens[validIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: validIndex,
          onTap: (idx) {
            setState(() {
              _currentIndex = idx;
            });
          },
          selectedItemColor: EcoTheme.primary,
          unselectedItemColor: EcoTheme.textMuted,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 8,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: items,
        ),
      ),
    );
  }
}
