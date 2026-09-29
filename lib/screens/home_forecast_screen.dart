import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/cache_indicator_badge.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/location_selector_sheet.dart';
import '../widgets/weather_gradient_card.dart';

/// Home Forecast Screen (Objectives 1, 2, 3)
/// Shows loading state, hero weather gradient card, 24-hr horizontal glance,
/// and instant outdoor activity overview.
class HomeForecastScreen extends StatelessWidget {
  final VoidCallback onNavigateToHourly;
  final VoidCallback onNavigateToActivities;

  const HomeForecastScreen({
    super.key,
    required this.onNavigateToHourly,
    required this.onNavigateToActivities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();
    final forecast = provider.forecast;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.wb_twilight_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('SkyCast'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city_rounded),
            tooltip: 'Select Hyperlocal Area',
            onPressed: () => _openLocationSheet(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Forecast',
            onPressed: provider.isLoading ? null : () => provider.refresh(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // Loading state handling (Outcome: "Home Forecast shows a loading state while forecast is fetched asynchronously")
          if (provider.isLoading && forecast == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Fetching hyperlocal forecast asynchronously...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checking persistent local storage cache...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          // Error state without cache
          if (forecast == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to Load Forecast',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage ?? 'Please check connection or retry.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => provider.refresh(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry Fetch'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Main loaded view with Pull-to-Refresh
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Local Storage Cache status indicator (Session 16)
                CacheIndicatorBadge(
                  isFromCache: forecast.isFromCache || provider.isOfflineMode,
                  lastCachedTimestamp: provider.lastCachedTimestamp,
                  onRefresh: () => provider.refresh(),
                  onSimulateOffline: () => provider.testOfflineSimulation(),
                ),

                // Dynamic Weather-Condition Gradient Hero Card
                WeatherGradientCard(
                  forecast: forecast,
                  onChangeLocation: () => _openLocationSheet(context, provider),
                ),

                const SizedBox(height: 14),

                // 24-Hour Quick Glance Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hourly Forecast (24h)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onNavigateToHourly,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                ),

                // Horizontal scrollable 24-hr glance
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: forecast.hourlyForecasts.length,
                    itemBuilder: (context, index) {
                      final hourly = forecast.hourlyForecasts[index];
                      final isSelected = provider.selectedHour?.time == hourly.time;

                      return HourlyForecastCard(
                        hourly: hourly,
                        isSelected: isSelected,
                        isHorizontalCompact: true,
                        onTap: () {
                          // Toggle or select hour
                          if (isSelected) {
                            provider.selectHour(null);
                          } else {
                            provider.selectHour(hourly);
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Activity Highlights Banner (Session 7, 9)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Outdoor Activity Suitability',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (provider.selectedHour != null)
                            Text(
                              'Evaluating for: ${provider.selectedHour!.formattedFullTime}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: onNavigateToActivities,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Details'),
                      ),
                    ],
                  ),
                ),

                // Top 3 Activity Cards Preview (Jogging, Picnic, Cycling)
                if (provider.activities.isNotEmpty)
                  ...provider.activities.take(3).map((activity) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: activity.suitability.color.withValues(alpha: 0.15),
                          child: Icon(activity.icon, color: activity.suitability.color),
                        ),
                        title: Text(
                          activity.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${activity.suitability.label} • Window: ${activity.bestTimeWindow}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: activity.suitability.color,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: activity.suitability.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${activity.score}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: activity.suitability.color,
                            ),
                          ),
                        ),
                        onTap: onNavigateToActivities,
                      ),
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openLocationSheet(BuildContext context, WeatherProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSelectorSheet(
        currentPresetId: provider.currentPresetId,
        onSelected: (id) => provider.setLocation(id),
      ),
    );
  }
}
