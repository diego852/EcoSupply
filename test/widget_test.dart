import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/main.dart';

void main() {
  testWidgets('EcoSupply app smoke test', (WidgetTester tester) async {
    // Build EcoSupply app and trigger a frame.
    await tester.pumpWidget(const EcoSupplyApp());

    // Verify WelcomeScreen renders
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Crear Cuenta'), findsOneWidget);
  });
}
