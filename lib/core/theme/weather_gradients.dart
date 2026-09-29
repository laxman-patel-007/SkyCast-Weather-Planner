import 'package:flutter/material.dart';
import '../../models/weather_condition.dart';

/// Reusable gradient decorations tailored to weather conditions
class WeatherGradients {
  static LinearGradient forCondition(WeatherCondition condition) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: condition.gradientColors,
      stops: const [0.0, 0.55, 1.0],
    );
  }

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x33000000),
    ],
  );

  static const LinearGradient glassHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x2EFFFFFF),
      Color(0x0AFFFFFF),
    ],
  );
}
