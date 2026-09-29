import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/hourly_forecast_card.dart';

/// Hourly Detail Screen (Objectives 1, 4)
/// Provides a scrollable 24-hour breakdown showing temperature, condition icon,
/// wind speed, and chance of rain for every single hour.
class HourlyDetailScreen extends StatelessWidget {
  final VoidCallback onNavigateToActivities;

  const HourlyDetailScreen({
    super.key,
    required this.onNavigateToActivities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();
    final forecast = provider.forecast;

    if (forecast == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hourly Forecast')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hourlyList = forecast.hourlyForecasts;
    final selected = provider.selectedHour ?? hourlyList.first;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('24-Hour Forecast Breakdown'),
            Text(
              forecast.locationName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Inspector Header Card for Selected Hour
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(selected.condition.icon, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.formattedFullTime,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              selected.condition.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      selected.formattedTemp,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol(Icons.air_rounded, 'Wind Speed', selected.formattedWind, theme),
                    _metricCol(Icons.water_drop_rounded, 'Rain Chance', selected.formattedRain, theme, color: const Color(0xFF0284C7)),
                    _metricCol(Icons.thermostat_outlined, 'Feels Like', selected.formattedFeelsLike, theme),
                    _metricCol(Icons.wb_sunny_rounded, 'UV Index', selected.formattedUv, theme),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: onNavigateToActivities,
                    icon: const Icon(Icons.directions_bike_rounded, size: 18),
                    label: Text('Plan Outdoor Activities for ${selected.formattedHour}'),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable 24-Hour List (Explicit Objective)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All 24 Hourly Intervals',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Tap any card to select',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              itemCount: hourlyList.length,
              itemBuilder: (context, index) {
                final hourly = hourlyList[index];
                final isSelected = provider.selectedHour?.time == hourly.time ||
                    (provider.selectedHour == null && index == 0);

                return HourlyForecastCard(
                  hourly: hourly,
                  isSelected: isSelected,
                  onTap: () {
                    provider.selectHour(hourly);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCol(IconData icon, String label, String value, ThemeData theme, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
