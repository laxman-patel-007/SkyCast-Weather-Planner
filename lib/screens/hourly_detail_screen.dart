import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/hourly_forecast_card.dart';

/// Hourly Detail Screen
/// Provides a scrollable 24-hour breakdown showing temperature, condition icon,
/// wind speed, and chance of rain for every single hour.
class HourlyDetailScreen extends StatelessWidget {
  final VoidCallback onNavigateToActivities;
  final bool isDesktopWeb;

  const HourlyDetailScreen({
    super.key,
    required this.onNavigateToActivities,
    this.isDesktopWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);
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
      appBar: isDesktopWeb
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '24-Hour Forecast',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.5,
                      color: AppTheme.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    forecast.locationName,
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
                  ),
                  tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: AppTheme.textSecondary(context)),
                  onPressed: () => provider.refresh(),
                  tooltip: 'Refresh',
                ),
                const SizedBox(width: 4),
              ],
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          final maxContentWidth = isWide ? 1440.0 : 680.0;

          if (isWide) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Selected Hour Inspector & Trends (Flex: 38)
                      Expanded(
                        flex: 38,
                        child: Column(
                          children: [
                            _buildInspectorCard(context, selected, theme),
                            const SizedBox(height: 14),
                            _buildDaySummaryCard(context, forecast, theme),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Right Column: Scrollable 24-Hour Timeline (Flex: 62)
                      Expanded(
                        flex: 62,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Hourly Timeline (24 Hours)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        color: AppTheme.textPrimary(context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Tap any hour to inspect details',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: hourlyList.length,
                                itemBuilder: (context, index) {
                                  final hourly = hourlyList[index];
                                  final isSelected = selected.time == hourly.time;

                                  return HourlyForecastCard(
                                    hourly: hourly,
                                    isSelected: isSelected,
                                    isFirst: index == 0,
                                    onTap: () {
                                      provider.selectHour(hourly);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Mobile / Compact Viewport (<960px)
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  _buildInspectorCard(context, selected, theme),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Hourly Timeline (24 Hours)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Tap any hour to inspect',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: hourlyList.length,
                      itemBuilder: (context, index) {
                        final hourly = hourlyList[index];
                        final isSelected = selected.time == hourly.time;

                        return HourlyForecastCard(
                          hourly: hourly,
                          isSelected: isSelected,
                          isFirst: index == 0,
                          onTap: () {
                            provider.selectHour(hourly);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInspectorCard(BuildContext context, dynamic selected, ThemeData theme) {
    final isDark = AppTheme.isDark(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF0F9FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFBAE6FD),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF0284C7).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selected.condition.gradientColors.first.withValues(alpha: isDark ? 0.24 : 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selected.condition.icon,
                        color: isDark ? const Color(0xFF38BDF8) : selected.condition.gradientColors.first,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.formattedFullTime,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: -0.2,
                              color: AppTheme.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selected.condition.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selected.formattedTemp,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          Divider(height: 18, color: AppTheme.borderColor(context)),
          Row(
            children: [
              Expanded(child: _metricCol(context, Icons.air_rounded, 'Wind', selected.formattedWind, isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
              Expanded(child: _metricCol(context, Icons.water_drop_rounded, 'Rain', selected.formattedRain, const Color(0xFF0284C7))),
              Expanded(child: _metricCol(context, Icons.thermostat_outlined, 'Feels Like', selected.formattedFeelsLike, isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
              Expanded(child: _metricCol(context, Icons.wb_sunny_rounded, 'UV Index', selected.formattedUv, const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _metricCol(context, Icons.water_rounded, 'Humidity', selected.formattedHumidity, isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
              Expanded(child: _metricCol(context, Icons.compress_rounded, 'Pressure', selected.formattedPressure, isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
              Expanded(child: _metricCol(context, Icons.visibility_outlined, 'Visibility', selected.formattedVisibility, isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: onNavigateToActivities,
              icon: const Icon(Icons.directions_bike_rounded, size: 16),
              label: Text(
                'Plan Activities for ${selected.formattedHour}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummaryCard(BuildContext context, dynamic forecast, ThemeData theme) {
    final isDark = AppTheme.isDark(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.24 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF0284C7)),
              ),
              const SizedBox(width: 8),
              Text(
                '24-Hour Atmospheric Outlook',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            forecast.weatherHeadline,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(context, 'Day Low', '${forecast.lowTemp.round()}°C', const Color(0xFF0284C7)),
              _summaryItem(context, 'Day High', '${forecast.highTemp.round()}°C', const Color(0xFFEA580C)),
              _summaryItem(context, 'Max Wind', '${forecast.currentWindSpeed.round()} km/h', isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
              _summaryItem(context, 'Air Quality', 'AQI ${forecast.airQualityIndex}', const Color(0xFF16A34A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _metricCol(BuildContext context, IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
