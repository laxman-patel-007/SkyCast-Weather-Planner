import 'dart:math';
import '../models/hourly_forecast.dart';
import '../models/weather_condition.dart';
import '../models/weather_forecast.dart';

/// Preset hyperlocal zones for testing and realistic weather evaluation
class WeatherLocationPreset {
  final String id;
  final String name;
  final String coordinates;
  final double baseTemp;
  final WeatherCondition baseCondition;
  final double baseWind;
  final int baseRain;
  final String description;

  const WeatherLocationPreset({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.baseTemp,
    required this.baseCondition,
    required this.baseWind,
    required this.baseRain,
    required this.description,
  });
}

/// Asynchronous Weather Data Service implementing Sessions 6 & 20
/// Uses Future, async/await, try/catch/finally for robust data fetching.
class WeatherService {
  static const List<WeatherLocationPreset> availablePresets = [
    WeatherLocationPreset(
      id: 'central_park',
      name: 'Central Green Valley, Sector 14',
      coordinates: '28.6139° N, 77.2090° E',
      baseTemp: 22.0,
      baseCondition: WeatherCondition.partlyCloudy,
      baseWind: 12.0,
      baseRain: 10,
      description: 'Temperate parkland with gentle canopy breezes and mild humidity.',
    ),
    WeatherLocationPreset(
      id: 'coastal_harbor',
      name: 'Coastal Bay Marina & Promenade',
      coordinates: '18.9220° N, 72.8347° E',
      baseTemp: 27.5,
      baseCondition: WeatherCondition.windy,
      baseWind: 26.0,
      baseRain: 25,
      description: 'Maritime waterfront with steady offshore wind and moderate UV.',
    ),
    WeatherLocationPreset(
      id: 'rainy_highlands',
      name: 'Highland Ridge & Forest Trails',
      coordinates: '31.1048° N, 77.1734° E',
      baseTemp: 16.0,
      baseCondition: WeatherCondition.rainy,
      baseWind: 18.0,
      baseRain: 65,
      description: 'Elevated topography experiencing recurring afternoon precipitation.',
    ),
    WeatherLocationPreset(
      id: 'sunny_plateau',
      name: 'Sunny Vista Commons',
      coordinates: '12.9716° N, 77.5946° E',
      baseTemp: 29.0,
      baseCondition: WeatherCondition.sunny,
      baseWind: 8.0,
      baseRain: 5,
      description: 'Clear radiant sunshine with peak midday solar exposure.',
    ),
  ];

  /// Asynchronously fetches a 24-hour hyperlocal forecast.
  /// Simulates realistic network transmission and non-blocking asynchronous dispatch.
  Future<WeatherForecast> fetchForecast({
    String presetId = 'central_park',
    bool simulateNetworkError = false,
  }) async {
    // Session 6: Asynchronous simulation using Future.delayed with try/catch/finally
    try {
      await Future.delayed(const Duration(milliseconds: 900));

      if (simulateNetworkError) {
        throw Exception('Simulated network timeout (Offline Mode demonstration)');
      }

      final preset = availablePresets.firstWhere(
        (p) => p.id == presetId,
        orElse: () => availablePresets.first,
      );

      final now = DateTime.now();
      final List<HourlyForecast> hourly = [];
      final random = Random();

      // Generate 24 sequential hourly forecasts starting from the current hour
      for (int i = 0; i < 24; i++) {
        final hourTime = now.add(Duration(hours: i));
        final hourOfDay = hourTime.hour;

        // Realistic diurnal temperature curve (cool in morning, peak at 2-3 PM)
        final diurnalOffset = sin((hourOfDay - 6) / 24.0 * 2 * pi) * 5.0;
        final noise = (random.nextDouble() - 0.5) * 1.5;
        final temp = (preset.baseTemp + diurnalOffset + noise);
        final feelsLike = temp + (preset.baseRain > 30 ? -1.0 : 1.2);

        // Wind fluctuation
        final wind = (preset.baseWind + sin(i / 3.0) * 4.0 + random.nextDouble() * 3.0).clamp(3.0, 50.0);

        // Rain chance based on preset base with diurnal variability
        int rainChance = preset.baseRain;
        if (hourOfDay >= 13 && hourOfDay <= 18 && preset.baseCondition == WeatherCondition.rainy) {
          rainChance = (rainChance + 20).clamp(0, 95);
        } else {
          rainChance = (rainChance + (random.nextInt(15) - 7)).clamp(0, 100);
        }

        // Determine condition per hour
        WeatherCondition hourCondition;
        if (rainChance >= 60) {
          hourCondition = rainChance > 80 ? WeatherCondition.heavyRain : WeatherCondition.rainy;
        } else if (wind >= 24) {
          hourCondition = WeatherCondition.windy;
        } else if (hourOfDay < 6 || hourOfDay > 20) {
          hourCondition = WeatherCondition.clearNight;
        } else if (preset.baseCondition == WeatherCondition.partlyCloudy) {
          hourCondition = i % 2 == 0 ? WeatherCondition.partlyCloudy : WeatherCondition.sunny;
        } else {
          hourCondition = preset.baseCondition;
        }

        // UV index estimation based on hour of day
        double uv = 0.0;
        if (hourOfDay >= 8 && hourOfDay <= 17) {
          uv = (sin((hourOfDay - 8) / 9.0 * pi) * 8.5).clamp(0.0, 11.0);
          if (rainChance > 40) uv *= 0.4;
        }

        hourly.add(HourlyForecast(
          time: hourTime,
          temperature: double.parse(temp.toStringAsFixed(1)),
          feelsLike: double.parse(feelsLike.toStringAsFixed(1)),
          condition: hourCondition,
          windSpeedKmh: double.parse(wind.toStringAsFixed(1)),
          rainChancePct: rainChance,
          humidity: (55 + sin(i / 4.0) * 15).clamp(30, 95).toInt(),
          uvIndex: double.parse(uv.toStringAsFixed(1)),
          summary: _getSummaryFor(hourCondition, temp, rainChance),
        ));
      }

      final temps = hourly.map((h) => h.temperature).toList();
      final minTemp = temps.reduce(min);
      final maxTemp = temps.reduce(max);

      return WeatherForecast(
        locationName: preset.name,
        areaCoordinates: preset.coordinates,
        currentTemp: hourly.first.temperature,
        highTemp: maxTemp,
        lowTemp: minTemp,
        currentCondition: hourly.first.condition,
        currentWindSpeed: hourly.first.windSpeedKmh,
        currentRainChance: hourly.first.rainChancePct,
        currentHumidity: hourly.first.humidity,
        airQualityIndex: 42 + random.nextInt(18),
        weatherHeadline: preset.description,
        hourlyForecasts: hourly,
        fetchedAt: DateTime.now(),
        isFromCache: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  String _getSummaryFor(WeatherCondition condition, double temp, int rainChance) {
    if (rainChance >= 60) return 'Rain gear advised; precipitation expected.';
    if (temp > 28) return 'Warm sunny conditions; carry sun protection.';
    if (temp < 14) return 'Crisp cooler air; light layers recommended.';
    return 'Comfortable outdoor conditions.';
  }
}
