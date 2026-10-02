import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skycast/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SkyCast app loads and displays navigation tabs and progress cues', (WidgetTester tester) async {
    // Set a phone/tablet viewport
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SkyCastApp());

    // Initially should show app title and navigation bar
    expect(find.text('SkyCast'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify presence of all 3 key navigation destinations
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Hourly (24h)'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);

    // Pump past the async timer delay
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    // Verify loaded elements
    expect(find.text('Hourly Forecast (24h)'), findsOneWidget);
    expect(find.text('Outdoor Activity Suitability'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
  });
}
