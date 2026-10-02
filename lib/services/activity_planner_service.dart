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
    final humidity = selectedHour?.humidity ?? forecast.currentHumidity;
    final hourlyList = forecast.hourlyForecasts;

    return [
      _evaluateJogging(temp, wind, rain, uv, condition, hourlyList),
      _evaluatePicnic(temp, wind, rain, uv, condition, hourlyList),
      _evaluateCycling(temp, wind, rain, uv, condition, hourlyList),
      _evaluateHiking(temp, wind, rain, uv, condition, hourlyList),
      _evaluateKayaking(temp, wind, rain, uv, condition, hourlyList),
      _evaluateTennis(temp, wind, rain, uv, condition, hourlyList),
      _evaluateStargazing(temp, wind, rain, uv, condition, humidity, hourlyList),
      _evaluateYoga(temp, wind, rain, uv, condition, hourlyList),
      _evaluateBouldering(temp, wind, rain, uv, condition, humidity, hourlyList),
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

  // --- 5. KAYAKING & PADDLEBOARDING ---
  ActivitySuggestion _evaluateKayaking(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 96;
    final List<String> reasons = [];
    final List<String> tips = [];

    if (condition == WeatherCondition.thunderstorm || rain >= 65) {
      score -= 75;
      reasons.add('Lightning and torrential rain present an immediate emergency hazard on open water bodies.');
      tips.add('Never paddle during active storm or lightning watches; seek immediate shoreline cover.');
    } else if (wind >= 24) {
      score -= 40;
      reasons.add('Stiff offshore gusts of ${wind.round()} km/h create surface chop and capsize danger.');
      tips.add('Stay within sheltered coves and paddle strictly parallel to the shore.');
    } else if (wind < 12) {
      reasons.add('Glassy water surface and calm winds (${wind.round()} km/h) offer sublime glide efficiency.');
      tips.add('Perfect morning conditions for stand-up paddleboarding and sea kayaking.');
    } else {
      reasons.add('Mild chop (${wind.round()} km/h) manageable for intermediate paddlers.');
    }

    if (temp >= 19 && temp <= 29) {
      reasons.add('Comfortable air temperature ($temp°C) minimizes cold shock risk.');
    } else if (temp < 13) {
      score -= 25;
      reasons.add('Cold ambient air ($temp°C) steepens hypothermia risks in event of an accidental spill.');
      tips.add('Wear a 3mm neoprene wetsuit or drysuit with thermal booties.');
    }

    score = score.clamp(10, 98);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.windSpeedKmh <= 14 && h.rainChancePct <= 15);

    return ActivitySuggestion(
      id: 'kayaking',
      title: 'Kayaking & Paddleboarding',
      category: 'Water & Aquatics',
      icon: Icons.kayaking_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '7:00 AM - 10:00 AM (Calm Water)',
      tips: tips.isNotEmpty ? tips : ['Always wear a US Coast Guard approved life vest (PFD).', 'Keep smartphone sealed in a waterproof floating pouch.'],
      idealTempRange: '18°C - 28°C',
      windTolerance: '< 16 km/h',
      rainTolerance: '< 10%',
    );
  }

  // --- 6. TENNIS & PICKLEBALL ---
  ActivitySuggestion _evaluateTennis(
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

    if (rain >= 20) {
      score -= 60;
      reasons.add('Moisture slicks hardcourt surfaces, increases slip injury danger, and degrades tennis ball felt.');
      tips.add('Play on indoor bubble courts or postpone until asphalt fully dries.');
    } else {
      reasons.add('Dry court surface guarantees proper ball bounce and slip-free lateral pivots.');
    }

    if (wind >= 22) {
      score -= 35;
      reasons.add('Wind gusts (${wind.round()} km/h) disrupt high toss trajectories and cause unpredictable ball flight.');
      tips.add('Hit with heavier topspin for extra court margin against crosswinds.');
    } else {
      reasons.add('Calm air (${wind.round()} km/h) allows surgical shot placement.');
    }

    if (temp >= 16 && temp <= 26) {
      reasons.add('Temperate warmth ($temp°C) provides optimal cardio stamina during long rallies.');
    } else if (temp > 31) {
      score -= 25;
      reasons.add('Radiant court heat ($temp°C) accelerates sweat and cramping.');
      tips.add('Keep electrolyte drinks courtside and switch wristbands frequently.');
    }

    score = score.clamp(10, 98);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.windSpeedKmh <= 14 && h.rainChancePct <= 10);

    return ActivitySuggestion(
      id: 'tennis',
      title: 'Tennis & Pickleball',
      category: 'Active Transit & Sport',
      icon: Icons.sports_tennis_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '8:00 AM - 10:30 AM',
      tips: tips.isNotEmpty ? tips : ['Wear non-marking hardcourt shoes with lateral support.', 'Keep spare overgrips for humid match play.'],
      idealTempRange: '16°C - 26°C',
      windTolerance: '< 15 km/h',
      rainTolerance: '< 5%',
    );
  }

  // --- 7. STARGAZING & NIGHT ASTRONOMY ---
  ActivitySuggestion _evaluateStargazing(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    int humidity,
    List<HourlyForecast> hourly,
  ) {
    int score = 96;
    final List<String> reasons = [];
    final List<String> tips = [];

    if (condition == WeatherCondition.clearNight) {
      reasons.add('Pristine nocturnal sky with crystal transparency maximizes deep-sky planetary and stellar contrast.');
      tips.add('Allow 20 minutes for rhodopsin dark-adaptation; avoid white flashlights.');
    } else if (condition == WeatherCondition.cloudy || condition == WeatherCondition.rainy || condition == WeatherCondition.heavyRain) {
      score -= 75;
      reasons.add('Heavy cloud cover completely obscures astronomical observations.');
      tips.add('Consult satellite infrared cloud maps for localized breaks in overcast.');
    } else if (condition == WeatherCondition.partlyCloudy) {
      score -= 30;
      reasons.add('Intermittent scattered clouds will partially interrupt continuous telescope tracking.');
    } else {
      score -= 40;
      reasons.add('Daylight or high solar glare prevents nocturnal telescope observation.');
      tips.add('Wait until astronomical twilight (after nautical dusk).');
    }

    if (humidity >= 85) {
      score -= 20;
      reasons.add('High relative humidity ($humidity%) creates rapid objective lens condensation and dewing.');
      tips.add('Attach dew heater strips or dew shields to telescope corrector plates.');
    }

    if (wind >= 20) {
      score -= 25;
      reasons.add('Breezy wind (${wind.round()} km/h) induces micro-vibrations across high-magnification tripod mounts.');
    }

    score = score.clamp(10, 99);
    final suitability = _scoreToSuitability(score);

    return ActivitySuggestion(
      id: 'stargazing',
      title: 'Stargazing & Astronomy',
      category: 'Night & Astronomy',
      icon: Icons.nightlight_round,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: '9:30 PM - 2:30 AM (Dark Sky)',
      tips: tips.isNotEmpty ? tips : ['Use red LED headlamps to preserve natural night vision.', 'Bring an insulated thermos and warm ground pad.'],
      idealTempRange: '8°C - 20°C',
      windTolerance: '< 15 km/h',
      rainTolerance: '< 5%',
    );
  }

  // --- 8. OUTDOOR YOGA & MEDITATION ---
  ActivitySuggestion _evaluateYoga(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    List<HourlyForecast> hourly,
  ) {
    int score = 94;
    final List<String> reasons = [];
    final List<String> tips = [];

    if (rain >= 15) {
      score -= 60;
      reasons.add('Damp grass and raindrops interrupt meditative stillness and compromise mat traction.');
      tips.add('Move practice to a sheltered wooden gazebo or covered veranda.');
    } else {
      reasons.add('Dry tranquil grounds provide serene surroundings for mindful movement.');
    }

    if (wind >= 18) {
      score -= 25;
      reasons.add('Wind gusts (${wind.round()} km/h) flip mat edges and create auditory distraction during breathwork.');
    } else {
      reasons.add('Gentle atmospheric stillness fosters undisturbed pranayama breathing.');
    }

    if (temp >= 18 && temp <= 25) {
      reasons.add('Mild temperature ($temp°C) allows comfortable muscular elongation and flow transitions.');
    } else if (temp < 14) {
      score -= 20;
      reasons.add('Brisk cool air ($temp°C) causes stiff joints during floor poses.');
      tips.add('Wear soft thermal leggings and keep a warm wrap for final Savasana.');
    } else if (temp > 30) {
      score -= 25;
      reasons.add('Excessive heat ($temp°C) causes premature fatigue during power flows.');
      tips.add('Practice in the shade and hydrate before beginning.');
    }

    score = score.clamp(10, 98);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.windSpeedKmh <= 12 && h.rainChancePct <= 10 && h.temperature >= 17);

    return ActivitySuggestion(
      id: 'yoga',
      title: 'Outdoor Yoga & Meditation',
      category: 'Wellness & Mindfulness',
      icon: Icons.self_improvement_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '6:30 AM - 8:30 AM (Sunrise Flow)',
      tips: tips.isNotEmpty ? tips : ['Use a non-slip natural rubber travel mat.', 'Pack a light fleece blanket for meditation.'],
      idealTempRange: '18°C - 25°C',
      windTolerance: '< 12 km/h',
      rainTolerance: '< 5%',
    );
  }

  // --- 9. ROCK CLIMBING & BOULDERING ---
  ActivitySuggestion _evaluateBouldering(
    double temp,
    double wind,
    int rain,
    double uv,
    WeatherCondition condition,
    int humidity,
    List<HourlyForecast> hourly,
  ) {
    int score = 95;
    final List<String> reasons = [];
    final List<String> tips = [];

    if (rain >= 15) {
      score -= 65;
      reasons.add('Wet rock loses up to 60% of friction coefficient; fragile sandstone can break under bodyweight.');
      tips.add('Never climb wet outdoor sandstone or limestone; respect crag ethics.');
    } else {
      reasons.add('Bone-dry rock surfaces provide secure friction for edging and smearing.');
    }

    if (humidity >= 75) {
      score -= 20;
      reasons.add('High relative humidity ($humidity%) creates glassy fingertip perspiration and chalk breakdown.');
      tips.add('Apply liquid chalk base-layer topped with chunky pure magnesium carbonate.');
    } else if (humidity <= 45) {
      reasons.add('Crisp low humidity provides prime "friction sending temps".');
    }

    if (temp >= 10 && temp <= 20) {
      reasons.add('Crisp air ($temp°C) keeps rubber sticky without softening rubber compounds.');
    } else if (temp > 27) {
      score -= 25;
      reasons.add('Hot ambient temperature ($temp°C) turns climbing shoe rubber soft and greasy.');
      tips.add('Seek north-facing shaded crags or climb at first light.');
    }

    score = score.clamp(10, 98);
    final suitability = _scoreToSuitability(score);
    final bestWindow = _findBestWindow(hourly, (h) => h.temperature <= 22 && h.rainChancePct <= 10);

    return ActivitySuggestion(
      id: 'bouldering',
      title: 'Rock Climbing & Bouldering',
      category: 'Outdoor Adventure',
      icon: Icons.terrain_rounded,
      suitability: suitability,
      score: score,
      justification: reasons.join(' '),
      bestTimeWindow: bestWindow.isNotEmpty ? bestWindow : '8:00 AM - 11:30 AM (Cool Rock)',
      tips: tips.isNotEmpty ? tips : ['Position bouldering crash pads over level landing zones.', 'Brush chalk off holds before leaving the crag.'],
      idealTempRange: '10°C - 20°C',
      windTolerance: '< 22 km/h',
      rainTolerance: '< 5%',
    );
  }

  // --- 10. PHOTOGRAPHY EVALUATION ---
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
