import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skycast/main.dart';
import 'package:skycast/widgets/hourly_forecast_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mobileScreenSizes = [
    const Size(320, 568),
    const Size(360, 640),
    const Size(375, 812),
    const Size(390, 844),
    const Size(412, 915),
  ];

  for (final size in mobileScreenSizes) {
    testWidgets('Check size ${size.width}x${size.height}', (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const SkyCastApp());
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Tap Tab 1: Hourly (24h)
      await tester.tap(find.text('Hourly (24h)'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Tap an hourly card in Tab 1
      await tester.tap(find.byType(HourlyForecastCard).first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Tap Tab 2: Activities
      await tester.tap(find.text('Activities'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
