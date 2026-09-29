import 'package:flutter/material.dart';

/// Represents hyperlocal weather condition types
enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  heavyRain,
  thunderstorm,
  windy,
  clearNight;

  String get displayName {
    switch (this) {
      case WeatherCondition.sunny:
        return 'Sunny & Clear';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return 'Overcast Cloudy';
      case WeatherCondition.rainy:
        return 'Light Rain';
      case WeatherCondition.heavyRain:
        return 'Heavy Showers';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.windy:
        return 'Breezy & Windy';
      case WeatherCondition.clearNight:
        return 'Clear Night';
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return Icons.grain_rounded;
      case WeatherCondition.heavyRain:
        return Icons.thunderstorm_outlined;
      case WeatherCondition.thunderstorm:
        return Icons.flash_on_rounded;
      case WeatherCondition.windy:
        return Icons.air_rounded;
      case WeatherCondition.clearNight:
        return Icons.nights_stay_rounded;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case WeatherCondition.sunny:
        return const [
          Color(0xFFFF7E40), // Warm sunrise orange
          Color(0xFFFFB347), // Golden amber
          Color(0xFF4A90E2), // Crisp cyan blue
        ];
      case WeatherCondition.partlyCloudy:
        return const [
          Color(0xFF3A7BD5),
          Color(0xFF3A6073),
          Color(0xFF4CA1AF),
        ];
      case WeatherCondition.cloudy:
        return const [
          Color(0xFF536976),
          Color(0xFF292E49),
          Color(0xFF1F1C2C),
        ];
      case WeatherCondition.rainy:
        return const [
          Color(0xFF2C3E50),
          Color(0xFF3498DB),
          Color(0xFF1B2838),
        ];
      case WeatherCondition.heavyRain:
        return const [
          Color(0xFF1A2A6C),
          Color(0xFF273C75),
          Color(0xFF0F172A),
        ];
      case WeatherCondition.thunderstorm:
        return const [
          Color(0xFF200122),
          Color(0xFF6F0000),
          Color(0xFF190A2E),
        ];
      case WeatherCondition.windy:
        return const [
          Color(0xFF00B4DB),
          Color(0xFF0083B0),
          Color(0xFF1E3C72),
        ];
      case WeatherCondition.clearNight:
        return const [
          Color(0xFF0F2027),
          Color(0xFF203A43),
          Color(0xFF2C5364),
        ];
    }
  }

  static WeatherCondition fromString(String? value) {
    if (value == null) return WeatherCondition.sunny;
    for (final condition in WeatherCondition.values) {
      if (condition.name.toLowerCase() == value.toLowerCase()) {
        return condition;
      }
    }
    return WeatherCondition.sunny;
  }
}
