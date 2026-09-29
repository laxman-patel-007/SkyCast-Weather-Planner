import 'package:flutter/material.dart';
import '../core/theme/weather_gradients.dart';
import '../models/weather_forecast.dart';
import 'metric_chip.dart';

/// Hero weather card with dynamic condition gradient and clear typography (Objectives & Session 9)
class WeatherGradientCard extends StatelessWidget {
  final WeatherForecast forecast;
  final VoidCallback onChangeLocation;

  const WeatherGradientCard({
    super.key,
    required this.forecast,
    required this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    final condition = forecast.currentCondition;
    final gradient = WeatherGradients.forCondition(condition);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: condition.gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient decoration
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              condition.icon,
              size: 160,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Header & Change Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  forecast.locationName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0, top: 2.0),
                            child: Text(
                              forecast.areaCoordinates,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: onChangeLocation,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Temperature & Condition Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large clear temperature typography
                    Text(
                      '${forecast.currentTemp.round()}°',
                      style: const TextStyle(
                        fontSize: 68,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -3,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(condition.icon, color: Colors.white, size: 22),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  condition.displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Feels like ${forecast.currentTemp.round()}° • H: ${forecast.highTemp.round()}° L: ${forecast.lowTemp.round()}°',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Meteorological Summary
                Text(
                  forecast.weatherHeadline,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                const SizedBox(height: 18),

                // 4-Card Responsive Metric Grid
                Row(
                  children: [
                    Expanded(
                      child: MetricChip(
                        icon: Icons.air_rounded,
                        label: 'Wind',
                        value: '${forecast.currentWindSpeed.round()} km/h',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricChip(
                        icon: Icons.water_drop_outlined,
                        label: 'Precipitation',
                        value: '${forecast.currentRainChance}%',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricChip(
                        icon: Icons.thermostat_rounded,
                        label: 'Humidity',
                        value: '${forecast.currentHumidity}%',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricChip(
                        icon: Icons.wb_sunny_outlined,
                        label: 'Air Quality',
                        value: 'AQI ${forecast.airQualityIndex}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
