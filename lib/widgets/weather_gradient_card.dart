import 'package:flutter/material.dart';
import '../core/theme/weather_gradients.dart';
import '../models/weather_condition.dart';
import '../models/weather_forecast.dart';
import 'metric_chip.dart';

/// Professional hero weather card with dynamic condition gradient,
/// visual temperature gauge, and plain-English meteorological indicators.
class WeatherGradientCard extends StatelessWidget {
  final WeatherForecast forecast;
  final VoidCallback onChangeLocation;

  const WeatherGradientCard({
    super.key,
    required this.forecast,
    required this.onChangeLocation,
  });

  String _getClothingTip(double temp, WeatherCondition condition, double wind, int rain) {
    if (rain >= 40) {
      return '☔ Rain alert: Carry an umbrella and wear water-resistant shoes.';
    }
    if (temp <= 12) {
      return '🧥 Chilly air: Bundle up with a warm jacket or coat.';
    } else if (temp <= 19) {
      return '🧥 Cool & crisp: A light jacket or sweater is ideal for outdoors.';
    } else if (temp >= 30) {
      return '☀️ Hot weather: Wear breathable clothes and stay hydrated.';
    } else if (wind >= 25) {
      return '💨 Breezy conditions: A windbreaker jacket is recommended.';
    } else {
      return '👕 Pleasant conditions: Comfortable for casual T-shirt & outdoor wear.';
    }
  }

  String _getWindDescription(double speed) {
    if (speed < 5) return 'Calm';
    if (speed < 12) return 'Light Breeze';
    if (speed < 20) return 'Gentle Breeze';
    if (speed < 30) return 'Moderate Wind';
    return 'Strong Wind';
  }

  String _getRainDescription(int rainPct) {
    if (rainPct < 15) return 'Dry • No Rain';
    if (rainPct < 40) return 'Low Rain Risk';
    if (rainPct < 70) return 'Scattered Rain';
    return 'Heavy Rain Likely';
  }

  String _getHumidityDescription(int humidity) {
    if (humidity < 35) return 'Dry Air';
    if (humidity < 65) return 'Comfortable';
    if (humidity < 80) return 'Humid';
    return 'Very Humid';
  }

  String _getAqiDescription(int aqi) {
    if (aqi <= 50) return 'Good • Clean';
    if (aqi <= 100) return 'Moderate Air';
    if (aqi <= 150) return 'Sensitive Beware';
    return 'Unhealthy';
  }

  @override
  Widget build(BuildContext context) {
    final condition = forecast.currentCondition;
    final gradient = WeatherGradients.forCondition(condition);
    final clothingTip = _getClothingTip(
      forecast.currentTemp,
      condition,
      forecast.currentWindSpeed,
      forecast.currentRainChance,
    );

    // Calculate temperature progress along the day's high/low
    final tempRange = forecast.highTemp - forecast.lowTemp;
    final tempProgress = tempRange > 0
        ? ((forecast.currentTemp - forecast.lowTemp) / tempRange).clamp(0.0, 1.0)
        : 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: condition.gradientColors.first.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient condition illustration watermark in background
          Positioned(
            right: -25,
            top: -25,
            child: Icon(
              condition.icon,
              size: 190,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Location Pill & Zone Switcher
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: onChangeLocation,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  forecast.locationName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Weather Condition Pill
                    Flexible(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(condition.icon, color: Colors.white, size: 15),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                condition.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Main Hero Temperature Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${forecast.currentTemp.round()}°',
                      style: const TextStyle(
                        fontSize: 68,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -3.5,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feels like ${forecast.currentTemp.round()}°',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            forecast.weatherHeadline,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Temperature Range Visual Indicator (Low to High bar)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'L: ${forecast.lowTemp.round()}°',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: tempProgress,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF38BDF8), Colors.white],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'H: ${forecast.highTemp.round()}°',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Everyday Clothing / Outdoor Advisory Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates_rounded,
                        color: Color(0xFFFDE047),
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          clothingTip,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Atmospheric Metrics: 2x2 grid on mobile screens (<560px), 4 across on desktop
                LayoutBuilder(
                  builder: (context, constraints) {
                    final windStatus = _getWindDescription(forecast.currentWindSpeed);
                    final rainStatus = _getRainDescription(forecast.currentRainChance);
                    final humStatus = _getHumidityDescription(forecast.currentHumidity);
                    final aqiStatus = _getAqiDescription(forecast.airQualityIndex);

                    final dewPoint = (forecast.currentTemp - ((100 - forecast.currentHumidity) / 5)).round();
                    final uvVal = forecast.hourlyForecasts.isNotEmpty ? forecast.hourlyForecasts.first.formattedUv : '0.0';

                    if (constraints.maxWidth < 560) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MetricChip(
                                  icon: Icons.air_rounded,
                                  label: 'Wind',
                                  value: '${forecast.currentWindSpeed.round()} km/h',
                                  status: windStatus,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MetricChip(
                                  icon: Icons.water_drop_outlined,
                                  label: 'Precipitation',
                                  value: '${forecast.currentRainChance}%',
                                  status: rainStatus,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: MetricChip(
                                  icon: Icons.thermostat_rounded,
                                  label: 'Humidity',
                                  value: '${forecast.currentHumidity}%',
                                  status: humStatus,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MetricChip(
                                  icon: Icons.eco_outlined,
                                  label: 'Air Quality',
                                  value: 'AQI ${forecast.airQualityIndex}',
                                  status: aqiStatus,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: MetricChip(
                                  icon: Icons.compress_rounded,
                                  label: 'Barometer',
                                  value: '${forecast.barometricPressure} hPa',
                                  status: forecast.barometricPressure < 1000 ? 'Low Pressure' : 'Stable Air',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MetricChip(
                                  icon: Icons.visibility_outlined,
                                  label: 'Visibility',
                                  value: '${forecast.visibilityKm.toStringAsFixed(1)} km',
                                  status: forecast.visibilityKm < 5.0 ? 'Misty / Low' : 'Clear Line-of-sight',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetricChip(
                                icon: Icons.air_rounded,
                                label: 'Wind',
                                value: '${forecast.currentWindSpeed.round()} km/h',
                                status: windStatus,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricChip(
                                icon: Icons.water_drop_outlined,
                                label: 'Precipitation',
                                value: '${forecast.currentRainChance}%',
                                status: rainStatus,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricChip(
                                icon: Icons.thermostat_rounded,
                                label: 'Humidity',
                                value: '${forecast.currentHumidity}%',
                                status: humStatus,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricChip(
                                icon: Icons.eco_outlined,
                                label: 'Air Quality',
                                value: 'AQI ${forecast.airQualityIndex}',
                                status: aqiStatus,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: MetricChip(
                                icon: Icons.compress_rounded,
                                label: 'Barometer',
                                value: '${forecast.barometricPressure} hPa',
                                status: forecast.barometricPressure < 1000 ? 'Low Elevation Pressure' : 'High Barometric Stability',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricChip(
                                icon: Icons.visibility_outlined,
                                label: 'Visibility',
                                value: '${forecast.visibilityKm.toStringAsFixed(1)} km',
                                status: forecast.visibilityKm < 5.0 ? 'Haze / Mist Alert' : 'Crystal Clarity',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricChip(
                                icon: Icons.wb_sunny_outlined,
                                label: 'Solar UV Index',
                                value: '$uvVal UV',
                                status: double.parse(uvVal) > 6.0 ? 'High Radiation' : 'Moderate Exposure',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricChip(
                                icon: Icons.dew_point,
                                label: 'Dew Point',
                                value: '$dewPoint°C',
                                status: dewPoint > 18 ? 'Muggy Air' : 'Comfortable Saturation',
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
