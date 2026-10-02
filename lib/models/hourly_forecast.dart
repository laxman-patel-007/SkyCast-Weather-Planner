import 'package:intl/intl.dart';
import 'weather_condition.dart';

/// Represents a single hour's hyperlocal atmospheric forecast
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final WeatherCondition condition;
  final double windSpeedKmh;
  final int rainChancePct;
  final int humidity;
  final double uvIndex;
  final String summary;
  final int pressureHpa;
  final double visibilityKm;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.windSpeedKmh,
    required this.rainChancePct,
    required this.humidity,
    required this.uvIndex,
    required this.summary,
    this.pressureHpa = 1013,
    this.visibilityKm = 10.0,
  });

  String get formattedHour => DateFormat('h a').format(time);
  String get formattedFullTime => DateFormat('EEEE, h:mm a').format(time);
  String get formattedTemp => '${temperature.round()}°';
  String get formattedFeelsLike => '${feelsLike.round()}°';
  String get formattedWind => '${windSpeedKmh.round()} km/h';
  String get formattedRain => '$rainChancePct%';
  String get formattedHumidity => '$humidity%';
  String get formattedUv => uvIndex.toStringAsFixed(1);
  String get formattedPressure => '$pressureHpa hPa';
  String get formattedVisibility => '${visibilityKm.toStringAsFixed(1)} km';

  bool get isRainLikely => rainChancePct >= 40;
  bool get isBreezy => windSpeedKmh >= 25;

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition.name,
      'windSpeedKmh': windSpeedKmh,
      'rainChancePct': rainChancePct,
      'humidity': humidity,
      'uvIndex': uvIndex,
      'summary': summary,
      'pressureHpa': pressureHpa,
      'visibilityKm': visibilityKm,
    };
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 22.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 22.0,
      condition: WeatherCondition.fromString(json['condition'] as String?),
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 10.0,
      rainChancePct: (json['rainChancePct'] as num?)?.toInt() ?? 10,
      humidity: (json['humidity'] as num?)?.toInt() ?? 55,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 3.0,
      summary: json['summary'] as String? ?? 'Fair outdoor weather',
      pressureHpa: (json['pressureHpa'] as num?)?.toInt() ?? 1013,
      visibilityKm: (json['visibilityKm'] as num?)?.toDouble() ?? 10.0,
    );
  }
}
