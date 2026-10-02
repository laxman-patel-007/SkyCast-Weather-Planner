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
  final int basePressure;
  final double baseVisibility;

  const WeatherLocationPreset({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.baseTemp,
    required this.baseCondition,
    required this.baseWind,
    required this.baseRain,
    required this.description,
    this.basePressure = 1013,
    this.baseVisibility = 10.0,
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
      basePressure: 1014,
      baseVisibility: 10.0,
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
      basePressure: 1011,
      baseVisibility: 12.0,
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
      basePressure: 998,
      baseVisibility: 6.5,
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
      basePressure: 1016,
      baseVisibility: 15.0,
    ),
    WeatherLocationPreset(
      id: 'alpine_summit',
      name: 'Alpine Pine Summit (Alt 2,400m)',
      coordinates: '32.2396° N, 77.1887° E',
      baseTemp: -2.5,
      baseCondition: WeatherCondition.snowy,
      baseWind: 28.0,
      baseRain: 70,
      description: 'Sub-zero mountain alpine ridge with blowing snow flurries and thin atmosphere.',
      basePressure: 785,
      baseVisibility: 4.0,
    ),
    WeatherLocationPreset(
      id: 'lakeside_mist',
      name: 'Lakeside Wetland Sanctuary',
      coordinates: '26.9124° N, 75.7873° E',
      baseTemp: 14.0,
      baseCondition: WeatherCondition.foggy,
      baseWind: 5.0,
      baseRain: 20,
      description: 'Valley basin characterized by dense morning mist, high dewpoint, and glass-still waters.',
      basePressure: 1018,
      baseVisibility: 2.2,
    ),
    WeatherLocationPreset(
      id: 'desert_oasis',
      name: 'Desert Oasis Dunes',
      coordinates: '26.2389° N, 73.0243° E',
      baseTemp: 38.5,
      baseCondition: WeatherCondition.heatWave,
      baseWind: 16.0,
      baseRain: 0,
      description: 'Arid desert thermal zone with extreme solar heating and low relative humidity.',
      basePressure: 1007,
      baseVisibility: 16.0,
    ),
    WeatherLocationPreset(
      id: 'stargazer_hill',
      name: 'Stargazer Hill Dark-Sky Reserve',
      coordinates: '30.3165° N, 78.0322° E',
      baseTemp: 11.0,
      baseCondition: WeatherCondition.clearNight,
      baseWind: 7.0,
      baseRain: 0,
      description: 'Protected astronomical dark-sky enclave with crystal stellar visibility and zero light pollution.',
      basePressure: 1022,
      baseVisibility: 20.0,
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
      await Future.delayed(const Duration(milliseconds: 350));

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
        final feelsLike = temp + (preset.baseRain > 30 ? -1.0 : (preset.baseTemp > 30 ? 3.0 : 0.8));

        // Wind fluctuation
        final wind = (preset.baseWind + sin(i / 3.0) * 4.0 + random.nextDouble() * 3.0).clamp(2.0, 65.0);

        // Rain/precipitation chance based on preset base with diurnal variability
        int rainChance = preset.baseRain;
        if (hourOfDay >= 13 && hourOfDay <= 18 && preset.baseCondition == WeatherCondition.rainy) {
          rainChance = (rainChance + 20).clamp(0, 95);
        } else {
          rainChance = (rainChance + (random.nextInt(15) - 7)).clamp(0, 100);
        }

        // Determine condition per hour
        WeatherCondition hourCondition;
        if (preset.baseCondition == WeatherCondition.snowy || temp <= 1.0) {
          hourCondition = wind > 35 ? WeatherCondition.hail : WeatherCondition.snowy;
        } else if (preset.baseCondition == WeatherCondition.heatWave || temp >= 35.0) {
          hourCondition = WeatherCondition.heatWave;
        } else if (preset.baseCondition == WeatherCondition.foggy && (hourOfDay <= 9 || hourOfDay >= 20)) {
          hourCondition = WeatherCondition.foggy;
        } else if (rainChance >= 60) {
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

        // Visibility calculation based on conditions
        double vis = preset.baseVisibility;
        if (hourCondition == WeatherCondition.foggy) {
          vis = (1.5 + random.nextDouble() * 1.5);
        } else if (hourCondition == WeatherCondition.heavyRain || hourCondition == WeatherCondition.snowy) {
          vis = (3.0 + random.nextDouble() * 2.0);
        } else if (hourCondition == WeatherCondition.rainy) {
          vis = (5.5 + random.nextDouble() * 2.0);
        }

        // UV index estimation based on hour of day and cloudiness
        double uv = 0.0;
        if (hourOfDay >= 8 && hourOfDay <= 17) {
          uv = (sin((hourOfDay - 8) / 9.0 * pi) * (preset.baseCondition == WeatherCondition.heatWave ? 11.5 : 8.5)).clamp(0.0, 12.0);
          if (rainChance > 40 || hourCondition == WeatherCondition.cloudy) uv *= 0.4;
          if (hourCondition == WeatherCondition.foggy) uv *= 0.3;
        }

        // Pressure variation
        final pressure = preset.basePressure + (sin(i / 6.0) * 3).round();

        hourly.add(HourlyForecast(
          time: hourTime,
          temperature: double.parse(temp.toStringAsFixed(1)),
          feelsLike: double.parse(feelsLike.toStringAsFixed(1)),
          condition: hourCondition,
          windSpeedKmh: double.parse(wind.toStringAsFixed(1)),
          rainChancePct: rainChance,
          humidity: (55 + sin(i / 4.0) * 15 + (hourCondition == WeatherCondition.foggy ? 30 : 0)).clamp(15, 98).toInt(),
          uvIndex: double.parse(uv.toStringAsFixed(1)),
          summary: _getSummaryFor(hourCondition, temp, rainChance),
          pressureHpa: pressure,
          visibilityKm: double.parse(vis.toStringAsFixed(1)),
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
        airQualityIndex: (preset.id == 'alpine_summit' ? 14 : (42 + random.nextInt(18))),
        weatherHeadline: preset.description,
        hourlyForecasts: hourly,
        fetchedAt: DateTime.now(),
        isFromCache: false,
        barometricPressure: hourly.first.pressureHpa,
        visibilityKm: hourly.first.visibilityKm,
      );
    } catch (e) {
      rethrow;
    }
  }

  String _getSummaryFor(WeatherCondition condition, double temp, int rainChance) {
    if (condition == WeatherCondition.snowy) return 'Freezing temperatures and snow flurries; winter gear essential.';
    if (condition == WeatherCondition.heatWave) return 'Dangerous excessive heat warning; limit direct outdoor exposure.';
    if (condition == WeatherCondition.foggy) return 'Reduced visibility due to fog; caution advised during travel.';
    if (condition == WeatherCondition.clearNight) return 'Pristine nocturnal sky; excellent conditions for stargazing.';
    if (rainChance >= 60) return 'Rain gear advised; precipitation expected.';
    if (temp > 28) return 'Warm sunny conditions; carry sun protection.';
    if (temp < 14) return 'Crisp cooler air; light layers recommended.';
    return 'Comfortable outdoor conditions.';
  }
}
