import 'package:flutter/material.dart';
import '../models/activity_suggestion.dart';
import '../models/hourly_forecast.dart';
import '../models/weather_condition.dart';
import '../models/weather_forecast.dart';

/// Intelligent recommendation engine that analyzes meteorological conditions
/// and evaluates outdoor activities with clear scientific justifications.
class ActivityPlannerService {
  /// Generate comprehensive activity suggestions based on current or selected forecast
  List<ActivitySuggestion> evaluateActivities({
    required WeatherForecast forecast,
    HourlyForecast? selectedHour,
  }) {
    // If a specific hour is selected in Hourly Detail, evaluate that hour;
    // otherwise evaluate the aggregate current forecast.
    final temp = selectedHour?.temperature ?? forecast.currentTemp;
    final wind = selectedHour?.windSpeedKmh ?? forecast.currentWindSpeed;
    final rain = selectedHour?.rainChancePct ?? forecast.currentRainChance;
    final uv = selectedHour?.uvIndex ?? 4.5;
    final condition = selectedHour?.condition ?? forecast.currentCondition;
    final hourlyList = forecast.hourlyForecasts;

    return [
      _evaluateJogging(temp, wind, rain, uv, condition, hourlyList),
      _evaluatePicnic(temp, wind, rain, uv, condition, hourlyList),
      _evaluateCycling(temp, wind, rain, uv, condition, hourlyList),
      _evaluateHiking(temp, wind, rain, uv, condition, hourlyList),
      _evaluatePhotography(temp, wind, rain, uv, condition, hourlyList),
    ];
  }

  // --- 1. JOGGING EVALUATION ---
  ActivitySuggestion _evaluateJogging(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 100;
    final List<String> reasons = [];
    final List<String> tips = [];

    // Temperature penalty
    if (temp >= 14 && temp <= 21) {
      reasons.add('Ambient temperature ($temp°C) is in the physiological sweet spot for cardiovascular exercise.');
      tips.add('Optimal thermoregulation: standard athletic t-shirt and shorts are ideal.');
    } else if (temp < 10) {
      final penalty = ((10 - temp) * 4).clamp(0, 30).toInt();
      score -= penalty;
      reasons.add('Cool air ($temp°C) increases muscular warm-up time.');
      tips.add('Wear moisture-wicking layers and warm up thoroughly.');
    } else if (temp > 25) {
      final penalty = ((temp - 25) * 5).clamp(0, 45).toInt();
      score -= penalty;
      reasons.add('Elevated warmth ($temp°C) raises dehydration and cardiac drift rates.');
      tips.add('Carry an electrolyte handheld flask; avoid heavy intervals in direct sun.');
    }

    // Rain penalty
    if (rain >= 50) {
      score -= 40;
      reasons.add('Substantial precipitation probability ($rain%) presents slippery asphalt and poor traction.');
      tips.add('Use trail shoes with deep outsole lugs and wear high-visibility gear.');
    } else if (rain >= 20) {
      score -= 15;
      reasons.add('Light scattered drizzle ($rain%) possible.');
      tips.add('Wear a water-resistant cap to keep droplets off eyes.');
    } else {
      reasons.add('Dry pavement ensures stable foot-strike cadence.');
    }

    // Wind penalty
    if (wind >= 30) {
      score -= 25;
      reasons.add('Stiff headwinds of ${wind.round()} km/h will significantly increase aerodynamic resistance.');
    } else if (wind < 15) {
      tips.add('Gentle breeze assists body cooling without wind chill.');
    }

    score = score.clamp(10, 98);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.temperature <= 22 && h.rainChancePct <= 20);

    return ActivitySuggestion(
      id: 'jogging',
      title: 'Jogging & Trail Running',
      category: 'Cardio & Fitness',
      icon: Icons.directions_run_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '6:00 AM - 8:30 AM',
      tips: tips.isNotEmpty ? tips : ['Stay hydrated and stretch pre-run.'],
      idealTempRange: '14°C - 21°C',
      windTolerance: '< 25 km/h',
      rainTolerance: '< 20%',
    );
  }

  // --- 2. PICNIC EVALUATION ---
  ActivitySuggestion _evaluatePicnic(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 100;
    final List<String> reasons = [];
    final List<String> tips = [];

    // Rain is a severe picnic blocker
    if (rain >= 40) {
      score -= 60;
      reasons.add('Rain probability ($rain%) creates damp lawns, making blanket seating unviable.');
      tips.add('Consider a covered gazebo or postpone outdoor dining.');
    } else if (rain >= 15) {
      score -= 20;
      reasons.add('Mild chance of rain ($rain%); bring a waterproof ground tarp.');
    } else {
      reasons.add('Dry grass and minimal rain threat ($rain%) provide ideal seating conditions.');
    }

    // Wind is also critical for food and parasols
    if (wind >= 25) {
      score -= 30;
      reasons.add('Wind gusts of ${wind.round()} km/h can disturb paperware, napkins, and lightweight food.');
      tips.add('Pack weighted clips or opt for sheltered grove areas.');
    } else {
      reasons.add('Calm breeze (${wind.round()} km/h) makes relaxing comfortable.');
    }

    // Temperature
    if (temp >= 19 && temp <= 27) {
      reasons.add('Delightful ambient temperature ($temp°C) suitable for extended lounging.');
    } else if (temp < 15) {
      score -= 25;
      reasons.add('Chilly temperature ($temp°C) makes sedentary outdoor seating uncomfortable.');
      tips.add('Pack thermal fleece blankets and thermos of hot tea.');
    } else if (temp > 30) {
      score -= 35;
      reasons.add('High temperature ($temp°C) risks rapid food spoilage and thermal discomfort.');
      tips.add('Use an insulated cooler bag with ice packs; seek deep tree shade.');
    }

    score = score.clamp(10, 99);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.rainChancePct <= 15 && h.windSpeedKmh <= 18 && h.temperature >= 18);

    return ActivitySuggestion(
      id: 'picnic',
      title: 'Park Picnic & Social Dining',
      category: 'Leisure & Family',
      icon: Icons.outdoor_grill_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '11:30 AM - 3:00 PM',
      tips: tips.isNotEmpty ? tips : ['Bring a waterproof tarp under your blanket.', 'Pack reusable sealed containers.'],
      idealTempRange: '19°C - 27°C',
      windTolerance: '< 18 km/h',
      rainTolerance: '< 10%',
    );
  }

  // --- 3. CYCLING EVALUATION ---
  ActivitySuggestion _evaluateCycling(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 100;
    final List<String> reasons = [];
    final List<String> tips = [];

    // Wind is crucial for cycling
    if (wind >= 30) {
      score -= 45;
      reasons.add('Dangerous crosswinds (${wind.round()} km/h) compromise bike stability and bike lane safety.');
      tips.add('Avoid deep aero carbon wheels; maintain two-handed brake hood grip.');
    } else if (wind >= 18) {
      score -= 15;
      reasons.add('Moderate breeze (${wind.round()} km/h) noticeable on open highways.');
      tips.add('Plan your route with a tailwind for the return leg.');
    } else {
      reasons.add('Gentle air currents (${wind.round()} km/h) ensure smooth pedaling dynamics.');
    }

    // Wet road traction
    if (rain >= 40) {
      score -= 40;
      reasons.add('Wet road asphalt reduces tire contact friction by up to 35% on turns and painted lines.');
      tips.add('Drop tire pressure by 5-10 PSI for improved wet contact patch and use fenders.');
    } else if (rain > 10) {
      score -= 10;
      reasons.add('Low chance of sprinkles ($rain%).');
    }

    // Temperature
    if (temp >= 15 && temp <= 25) {
      reasons.add('Air velocity keeps body pleasantly cool at $temp°C.');
    } else if (temp > 30) {
      score -= 20;
      reasons.add('High temperature ($temp°C) accelerates electrolyte loss during continuous cadence.');
      tips.add('Refill bidons every 45 minutes with isotonic minerals.');
    }

    score = score.clamp(10, 97);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.windSpeedKmh <= 16 && h.rainChancePct <= 15);

    return ActivitySuggestion(
      id: 'cycling',
      title: 'Road & Commuter Cycling',
      category: 'Active Transit & Sport',
      icon: Icons.pedal_bike_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '7:00 AM - 10:00 AM',
      tips: tips.isNotEmpty ? tips : ['Check tire pressure and wear safety helmet.', 'Mount front and rear strobe lights.'],
      idealTempRange: '16°C - 25°C',
      windTolerance: '< 20 km/h',
      rainTolerance: '< 15%',
    );
  }

  // --- 4. HIKING EVALUATION ---
  ActivitySuggestion _evaluateHiking(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 95;
    final List<String> reasons = [];
    final List<String> tips = [];

    if (rain >= 45) {
      score -= 45;
      reasons.add('Rain creates mud hazards, swollen creek crossings, and slick rock surfaces.');
      tips.add('Sturdy trekking poles and waterproof GORE-TEX boots are mandatory.');
    } else {
      reasons.add('Trail condition is dry with low slip risk.');
    }

    if (uv >= 7.0) {
      score -= 15;
      reasons.add('High UV index (${uv.toStringAsFixed(1)}) requires strong solar radiation protection at ridge lines.');
      tips.add('Apply SPF 50+ sunscreen and wear a wide-brim UV hat.');
    }

    if (temp > 28) {
      score -= 25;
      reasons.add('High temperature ($temp°C) steepens water consumption.');
      tips.add('Pack at least 2.5 liters of fluid per 3 hours of trail time.');
    }

    score = score.clamp(10, 95);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.rainChancePct <= 20 && h.temperature <= 26);

    return ActivitySuggestion(
      id: 'hiking',
      title: 'Hiking & Nature Walks',
      category: 'Outdoor Adventure',
      icon: Icons.hiking_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '8:00 AM - 11:30 AM',
      tips: tips.isNotEmpty ? tips : ['Stay on marked trails and check offline map navigation.'],
      idealTempRange: '15°C - 24°C',
      windTolerance: '< 30 km/h',
      rainTolerance: '< 25%',
    );
  }

  // --- 5. PHOTOGRAPHY EVALUATION ---
  ActivitySuggestion _evaluatePhotography(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 88;
    final List<String> reasons = [];
    final List<String> tips = [];

    if (condition == WeatherCondition.partlyCloudy || condition == WeatherCondition.sunny) {
      reasons.add('Excellent dynamic lighting with natural cloud diffusers for outdoor portraits and landscapes.');
      tips.add('Golden hour around dawn or dusk produces warm rim-lighting.');
    } else if (condition == WeatherCondition.rainy || condition == WeatherCondition.heavyRain) {
      score -= 35;
      reasons.add('Moisture requires weather-sealed bodies and camera rain sleeves.');
      tips.add('Capture vibrant puddle reflections and moody misty foliage.');
    }

    if (wind > 25) {
      score -= 15;
      reasons.add('Tripod stability may be compromised on exposed bluffs.');
      tips.add('Hang your backpack from the center column hook to weight the tripod.');
    }

    score = score.clamp(20, 98);
    final suitability = _scoreToSuitability(score);

    return ActivitySuggestion(
      id: 'photography',
      title: 'Outdoor Landscape Photography',
      category: 'Creative Arts',
      icon: Icons.camera_alt_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: '5:30 PM - 7:00 PM (Golden Hour)',
      tips: tips.isNotEmpty ? tips : ['Use a circular polarizer filter to reduce glare.'],
      idealTempRange: '12°C - 26°C',
      windTolerance: '< 22 km/h',
      rainTolerance: '< 20%',
    );
  }

  SuitabilityLevel _scoreToSuitability(int score) {
    if (score >= 82) return SuitabilityLevel.ideal;
    if (score >= 68) return SuitabilityLevel.good;
    if (score >= 50) return SuitabilityLevel.moderate;
    if (score >= 35) return SuitabilityLevel.caution;
    return SuitabilityLevel.notRecommended;
  }

  String _findBestWindow(List<HourlyForecast> hourly, bool Function(HourlyForecast) filter) {
    if (hourly.isEmpty) return '';
    HourlyForecast? start;
    HourlyForecast? end;

    for (final h in hourly) {
      // Focus on daytime hours (6 AM to 8 PM)
      if (h.time.hour >= 6 && h.time.hour <= 20 && filter(h)) {
        start ??= h;
        end = h;
      }
    }

    if (start != null && end != null) {
      if (start.formattedHour == end.formattedHour) {
        return 'Around ${start.formattedHour}';
      }
      return '${start.formattedHour} - ${end.formattedHour}';
    }
    return '';
  }
}
