import 'hourly_forecast.dart';
import 'weather_condition.dart';

/// Complete hyperlocal weather forecast entity containing 24-hour predictions
class WeatherForecast {
  final String locationName;
  final String areaCoordinates;
  final double currentTemp;
  final double highTemp;
  final double lowTemp;
  final WeatherCondition currentCondition;
  final double currentWindSpeed;
  final int currentRainChance;
  final int currentHumidity;
  final int airQualityIndex;
  final String weatherHeadline;
  final List<HourlyForecast> hourlyForecasts;
  final DateTime fetchedAt;
  final bool isFromCache;
  final int barometricPressure;
  final double visibilityKm;

  WeatherForecast({
    required this.locationName,
    required this.areaCoordinates,
    required this.currentTemp,
    required this.highTemp,
    required this.lowTemp,
    required this.currentCondition,
    required this.currentWindSpeed,
    required this.currentRainChance,
    required this.currentHumidity,
    required this.airQualityIndex,
    required this.weatherHeadline,
    required this.hourlyForecasts,
    required this.fetchedAt,
    this.isFromCache = false,
    this.barometricPressure = 1013,
    this.visibilityKm = 10.0,
  });

  WeatherForecast copyWith({
    String? locationName,
    String? areaCoordinates,
    double? currentTemp,
    double? highTemp,
    double? lowTemp,
    WeatherCondition? currentCondition,
    double? currentWindSpeed,
    int? currentRainChance,
    int? currentHumidity,
    int? airQualityIndex,
    String? weatherHeadline,
    List<HourlyForecast>? hourlyForecasts,
    DateTime? fetchedAt,
    bool? isFromCache,
    int? barometricPressure,
    double? visibilityKm,
  }) {
    return WeatherForecast(
      locationName: locationName ?? this.locationName,
      areaCoordinates: areaCoordinates ?? this.areaCoordinates,
      currentTemp: currentTemp ?? this.currentTemp,
      highTemp: highTemp ?? this.highTemp,
      lowTemp: lowTemp ?? this.lowTemp,
      currentCondition: currentCondition ?? this.currentCondition,
      currentWindSpeed: currentWindSpeed ?? this.currentWindSpeed,
      currentRainChance: currentRainChance ?? this.currentRainChance,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      airQualityIndex: airQualityIndex ?? this.airQualityIndex,
      weatherHeadline: weatherHeadline ?? this.weatherHeadline,
      hourlyForecasts: hourlyForecasts ?? this.hourlyForecasts,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isFromCache: isFromCache ?? this.isFromCache,
      barometricPressure: barometricPressure ?? this.barometricPressure,
      visibilityKm: visibilityKm ?? this.visibilityKm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationName': locationName,
      'areaCoordinates': areaCoordinates,
      'currentTemp': currentTemp,
      'highTemp': highTemp,
      'lowTemp': lowTemp,
      'currentCondition': currentCondition.name,
      'currentWindSpeed': currentWindSpeed,
      'currentRainChance': currentRainChance,
      'currentHumidity': currentHumidity,
      'airQualityIndex': airQualityIndex,
      'weatherHeadline': weatherHeadline,
      'hourlyForecasts': hourlyForecasts.map((h) => h.toJson()).toList(),
      'fetchedAt': fetchedAt.toIso8601String(),
      'isFromCache': isFromCache,
      'barometricPressure': barometricPressure,
      'visibilityKm': visibilityKm,
    };
  }

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final rawHourly = json['hourlyForecasts'] as List<dynamic>? ?? [];
    return WeatherForecast(
      locationName: json['locationName'] as String? ?? 'Hyperlocal Sector',
      areaCoordinates: json['areaCoordinates'] as String? ?? '28.6139° N, 77.2090° E',
      currentTemp: (json['currentTemp'] as num?)?.toDouble() ?? 24.0,
      highTemp: (json['highTemp'] as num?)?.toDouble() ?? 28.0,
      lowTemp: (json['lowTemp'] as num?)?.toDouble() ?? 18.0,
      currentCondition: WeatherCondition.fromString(json['currentCondition'] as String?),
      currentWindSpeed: (json['currentWindSpeed'] as num?)?.toDouble() ?? 12.0,
      currentRainChance: (json['currentRainChance'] as num?)?.toInt() ?? 15,
      currentHumidity: (json['currentHumidity'] as num?)?.toInt() ?? 50,
      airQualityIndex: (json['airQualityIndex'] as num?)?.toInt() ?? 42,
      weatherHeadline: json['weatherHeadline'] as String? ?? 'Optimal outdoor conditions expected today.',
      hourlyForecasts: rawHourly
          .map((item) => HourlyForecast.fromJson(item as Map<String, dynamic>))
          .toList(),
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ?? DateTime.now(),
      isFromCache: json['isFromCache'] as bool? ?? false,
      barometricPressure: (json['barometricPressure'] as num?)?.toInt() ?? 1013,
      visibilityKm: (json['visibilityKm'] as num?)?.toDouble() ?? 10.0,
    );
  }
}
