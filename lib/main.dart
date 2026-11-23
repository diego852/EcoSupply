import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EcoSupplyApp());
}

class EcoSupplyApp extends StatefulWidget {
  const EcoSupplyApp({super.key});

  @override
  State<EcoSupplyApp> createState() => _EcoSupplyAppState();
}

class _EcoSupplyAppState extends State<EcoSupplyApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'EcoSupply',
        debugShowCheckedModeBanner: false,
        theme: EcoTheme.themeData,
        home: const WelcomeScreen(),
      ),
    );
  }
}
