import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skycast/models/activity_suggestion.dart';
import 'package:skycast/models/hourly_forecast.dart';
import 'package:skycast/models/weather_condition.dart';
import 'package:skycast/models/weather_forecast.dart';
import 'package:skycast/providers/theme_provider.dart';
import 'package:skycast/services/activity_planner_service.dart';

void main() {
  group('Theme Mode & Persistence Tests', () {
    test('ThemeProvider initializes and toggles theme with persistence', () async {
      SharedPreferences.setMockInitialValues({});
      final themeProvider = ThemeProvider();
      await themeProvider.init();

      expect(themeProvider.themeMode, equals(ThemeMode.light));

      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.isDarkMode, isTrue);

      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.light));
      expect(themeProvider.isDarkMode, isFalse);

      // Verify persistence by initializing a new instance
      final reloadedProvider = ThemeProvider();
      await reloadedProvider.init();
      expect(reloadedProvider.themeMode, equals(ThemeMode.light));
    });
  });
  group('Syllabus Session 4 & 5: Dart OOP & Model Serialization Tests', () {
    test('WeatherCondition parses from strings accurately', () {
      expect(WeatherCondition.fromString('sunny'), equals(WeatherCondition.sunny));
      expect(WeatherCondition.fromString('rainy'), equals(WeatherCondition.rainy));
      expect(WeatherCondition.fromString('unknown_condition'), equals(WeatherCondition.sunny));
    });

    test('HourlyForecast serializes to and from JSON preserving all metrics', () {
      final now = DateTime(2026, 9, 29, 14, 0);
      final hourly = HourlyForecast(
        time: now,
        temperature: 24.5,
        feelsLike: 25.0,
        condition: WeatherCondition.partlyCloudy,
        windSpeedKmh: 14.2,
        rainChancePct: 20,
        humidity: 58,
        uvIndex: 5.4,
        summary: 'Gentle breeze and partly cloudy',
      );

      final json = hourly.toJson();
      expect(json['temperature'], equals(24.5));
      expect(json['windSpeedKmh'], equals(14.2));
      expect(json['rainChancePct'], equals(20));

      final restored = HourlyForecast.fromJson(json);
      expect(restored.temperature, equals(24.5));
      expect(restored.condition, equals(WeatherCondition.partlyCloudy));
      expect(restored.windSpeedKmh, equals(14.2));
      expect(restored.rainChancePct, equals(20));
      expect(restored.formattedTemp, equals('25°'));
      expect(restored.formattedWind, equals('14 km/h'));
    });

    test('WeatherForecast model copyWith works correctly', () {
      final forecast = WeatherForecast(
        locationName: 'Central Park',
        areaCoordinates: '0.0, 0.0',
        currentTemp: 22.0,
        highTemp: 26.0,
        lowTemp: 18.0,
        currentCondition: WeatherCondition.sunny,
        currentWindSpeed: 10.0,
        currentRainChance: 5,
        currentHumidity: 50,
        airQualityIndex: 40,
        weatherHeadline: 'Sunny day',
        hourlyForecasts: [],
        fetchedAt: DateTime.now(),
        isFromCache: false,
      );

      final cachedCopy = forecast.copyWith(isFromCache: true);
      expect(cachedCopy.isFromCache, isTrue);
      expect(cachedCopy.locationName, equals('Central Park'));
    });
  });

  group('Session 6 & Capstone Logic: Activity Planner Recommendation Engine Tests', () {
    final planner = ActivityPlannerService();

    test('Evaluates high score for Jogging in ideal conditions', () {
      final forecast = WeatherForecast(
        locationName: 'Test Zone',
        areaCoordinates: '0, 0',
        currentTemp: 18.0, // Ideal running temp
        highTemp: 22.0,
        lowTemp: 14.0,
        currentCondition: WeatherCondition.partlyCloudy,
        currentWindSpeed: 8.0, // Calm wind
        currentRainChance: 5, // Dry
        currentHumidity: 50,
        airQualityIndex: 30,
        weatherHeadline: 'Optimal conditions',
        hourlyForecasts: [],
        fetchedAt: DateTime.now(),
      );

      final activities = planner.evaluateActivities(forecast: forecast);
      final jogging = activities.firstWhere((a) => a.id == 'jogging');

      expect(jogging.suitability, equals(SuitabilityLevel.ideal));
      expect(jogging.score, greaterThanOrEqualTo(85));
      expect(jogging.justification, contains('physiological sweet spot'));
    });

    test('Penalizes Picnic when rain probability is high', () {
      final forecast = WeatherForecast(
        locationName: 'Test Zone',
        areaCoordinates: '0, 0',
        currentTemp: 22.0,
        highTemp: 24.0,
        lowTemp: 18.0,
        currentCondition: WeatherCondition.rainy,
        currentWindSpeed: 12.0,
        currentRainChance: 70, // High rain
        currentHumidity: 85,
        airQualityIndex: 30,
        weatherHeadline: 'Wet rain expected',
        hourlyForecasts: [],
        fetchedAt: DateTime.now(),
      );

      final activities = planner.evaluateActivities(forecast: forecast);
      final picnic = activities.firstWhere((a) => a.id == 'picnic');

      expect(picnic.suitability == SuitabilityLevel.caution ||
             picnic.suitability == SuitabilityLevel.notRecommended, isTrue);
      expect(picnic.justification, contains('damp lawns'));
    });

    test('Penalizes Cycling when winds are severe', () {
      final forecast = WeatherForecast(
        locationName: 'Test Zone',
        areaCoordinates: '0, 0',
        currentTemp: 20.0,
        highTemp: 22.0,
        lowTemp: 16.0,
        currentCondition: WeatherCondition.windy,
        currentWindSpeed: 38.0, // Dangerous crosswinds
        currentRainChance: 10,
        currentHumidity: 50,
        airQualityIndex: 30,
        weatherHeadline: 'High wind warnings',
        hourlyForecasts: [],
        fetchedAt: DateTime.now(),
      );

      final activities = planner.evaluateActivities(forecast: forecast);
      final cycling = activities.firstWhere((a) => a.id == 'cycling');

      expect(cycling.score, lessThan(65));
      expect(cycling.justification, contains('crosswinds'));
    });

    test('Evaluates expanded weather conditions accurately', () {
      expect(WeatherCondition.fromString('snowy'), equals(WeatherCondition.snowy));
      expect(WeatherCondition.fromString('foggy'), equals(WeatherCondition.foggy));
      expect(WeatherCondition.fromString('hail'), equals(WeatherCondition.hail));
      expect(WeatherCondition.fromString('heatWave'), equals(WeatherCondition.heatWave));
      expect(WeatherCondition.snowy.displayName, contains('Snow'));
      expect(WeatherCondition.heatWave.displayName, contains('Heat Wave'));
    });

    test('ActivityPlannerService evaluates full catalog of 10 diverse activities', () {
      final forecast = WeatherForecast(
        locationName: 'Stargazer Hill',
        areaCoordinates: '0, 0',
        currentTemp: 18.0,
        highTemp: 22.0,
        lowTemp: 12.0,
        currentCondition: WeatherCondition.clearNight,
        currentWindSpeed: 6.0,
        currentRainChance: 0,
        currentHumidity: 45,
        airQualityIndex: 20,
        weatherHeadline: 'Pristine nocturnal dark sky',
        hourlyForecasts: [],
        fetchedAt: DateTime.now(),
        barometricPressure: 1018,
        visibilityKm: 20.0,
      );

      final activities = planner.evaluateActivities(forecast: forecast);
      expect(activities.length, equals(10));

      final activityIds = activities.map((a) => a.id).toSet();
      expect(activityIds, containsAll([
        'jogging',
        'picnic',
        'cycling',
        'hiking',
        'kayaking',
        'tennis',
        'stargazing',
        'yoga',
        'bouldering',
        'photography',
      ]));

      // Stargazing should score very high on a clear night with low wind and no rain
      final stargazing = activities.firstWhere((a) => a.id == 'stargazing');
      expect(stargazing.score, greaterThanOrEqualTo(85));
      expect(stargazing.suitability, equals(SuitabilityLevel.ideal));
      expect(stargazing.justification, contains('Pristine nocturnal sky'));

      // Kayaking on calm water (6 km/h wind) should score well
      final kayaking = activities.firstWhere((a) => a.id == 'kayaking');
      expect(kayaking.score, greaterThan(80));
      expect(kayaking.justification, contains('Glassy water'));
    });
  });
}

