import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/activity_suggestion.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';
import '../widgets/cache_indicator_badge.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/location_selector_sheet.dart';
import '../widgets/weather_gradient_card.dart';

/// Home Forecast Screen
/// Shows loading state, hero weather gradient card, 24-hr horizontal glance,
/// and instant outdoor activity overview. Adapts to full-area 2-column web dashboard on wide screens.
class HomeForecastScreen extends StatelessWidget {
  final VoidCallback onNavigateToHourly;
  final VoidCallback onNavigateToActivities;
  final bool isDesktopWeb;

  const HomeForecastScreen({
    super.key,
    required this.onNavigateToHourly,
    required this.onNavigateToActivities,
    this.isDesktopWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);
    final provider = context.watch<WeatherProvider>();
    final forecast = provider.forecast;

    return Scaffold(
      appBar: isDesktopWeb
          ? null
          : AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'SkyCast',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                        color: AppTheme.textPrimary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                  tooltip: 'Refresh Forecast',
                  onPressed: provider.isLoading ? null : () => provider.refresh(),
                ),
                const SizedBox(width: 4),
              ],
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          final maxContentWidth = isWide ? 1440.0 : 680.0;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Builder(
                builder: (context) {
                  // Loading state handling
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
                            'Fetching hyperlocal forecast...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Checking local cache for instant load...',
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

                  // Responsive Full-Area Desktop Web Dashboard
                  if (isWide) {
                    return RefreshIndicator(
                      onRefresh: () => provider.refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Dashboard Column (Hero + Timeline)
                              Expanded(
                                flex: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CacheIndicatorBadge(
                                      isFromCache: forecast.isFromCache || provider.isOfflineMode,
                                      lastCachedTimestamp: provider.lastCachedTimestamp,
                                      onRefresh: () => provider.refresh(),
                                      onSimulateOffline: () => provider.testOfflineSimulation(),
                                    ),
                                    WeatherGradientCard(
                                      forecast: forecast,
                                      onChangeLocation: () => _openLocationSheet(context, provider),
                                    ),
                                    const SizedBox(height: 14),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Hourly Forecast (24h)',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.3,
                                                color: AppTheme.textPrimary(context),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: onNavigateToHourly,
                                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                            label: const Text(
                                              'Explore 24h',
                                              style: TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 135,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        itemCount: forecast.hourlyForecasts.length,
                                        itemBuilder: (context, index) {
                                          final hourly = forecast.hourlyForecasts[index];
                                          final isSelected = provider.selectedHour?.time == hourly.time;

                                          return HourlyForecastCard(
                                            hourly: hourly,
                                            isSelected: isSelected,
                                            isHorizontalCompact: true,
                                            isFirst: index == 0,
                                            onTap: () {
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
                                  ],
                                ),
                              ),

                              const SizedBox(width: 24),

                              // Right Dashboard Column (Activity Engine + Microclimate Switcher)
                              Expanded(
                                flex: 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Outdoor Activity Suitability',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.3,
                                                    color: AppTheme.textPrimary(context),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (provider.selectedHour != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Text(
                                                      'Slot: ${provider.selectedHour!.formattedFullTime}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF0284C7),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: onNavigateToActivities,
                                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                            label: const Text(
                                              'View All',
                                              style: TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Top Activities
                                    if (provider.activities.isNotEmpty)
                                      ...provider.activities.take(4).map((activity) => _buildActivityItem(activity)),

                                    const SizedBox(height: 10),

                                    // Microclimate Stations card
                                    _buildQuickStationCard(context, provider),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    );
                  }

                  // Main loaded view for Mobile / Compact Viewports (<960px)
                  return RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        CacheIndicatorBadge(
                          isFromCache: forecast.isFromCache || provider.isOfflineMode,
                          lastCachedTimestamp: provider.lastCachedTimestamp,
                          onRefresh: () => provider.refresh(),
                          onSimulateOffline: () => provider.testOfflineSimulation(),
                        ),
                        WeatherGradientCard(
                          forecast: forecast,
                          onChangeLocation: () => _openLocationSheet(context, provider),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Hourly Forecast (24h)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: AppTheme.textPrimary(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: onNavigateToHourly,
                                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                label: const Text(
                                  'Explore 24h',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 135,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: forecast.hourlyForecasts.length,
                            itemBuilder: (context, index) {
                              final hourly = forecast.hourlyForecasts[index];
                              final isSelected = provider.selectedHour?.time == hourly.time;

                              return HourlyForecastCard(
                                hourly: hourly,
                                isSelected: isSelected,
                                isHorizontalCompact: true,
                                isFirst: index == 0,
                                onTap: () {
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Outdoor Activity Suitability',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                        color: AppTheme.textPrimary(context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (provider.selectedHour != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text(
                                          'Evaluating for: ${provider.selectedHour!.formattedFullTime}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0284C7),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: onNavigateToActivities,
                                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                label: const Text(
                                  'View All',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (provider.activities.isNotEmpty)
                          ...provider.activities.take(4).map((activity) => _buildActivityItem(activity)),
                        const SizedBox(height: 28),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(ActivitySuggestion activity) {
    return Builder(
      builder: (context) {
        final suitability = activity.suitability;
        final isDark = AppTheme.isDark(context);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          color: AppTheme.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppTheme.borderColor(context),
              width: 1.0,
            ),
          ),
          child: InkWell(
            onTap: onNavigateToActivities,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: suitability.color.withValues(alpha: isDark ? 0.24 : 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(activity.icon, color: suitability.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppTheme.textPrimary(context),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: suitability.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              suitability.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: suitability.color,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '• Window: ${activity.bestTimeWindow}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: suitability.color.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: suitability.color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${activity.score}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: suitability.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStationCard(BuildContext context, WeatherProvider provider) {
    final isDark = AppTheme.isDark(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.borderColor(context), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  child: const Icon(Icons.sensors_rounded, size: 16, color: Color(0xFF0284C7)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Microclimate Weather Stations',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppTheme.textPrimary(context),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Switch local sensor feed to evaluate alternate topography & elevation:',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context), height: 1.3),
            ),
            const SizedBox(height: 10),
            ...WeatherService.availablePresets.map((preset) {
              final isCurrent = preset.id == provider.currentPresetId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: InkWell(
                  onTap: isCurrent ? null : () => provider.setLocation(preset.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? (isDark ? const Color(0xFF0369A1).withValues(alpha: 0.28) : const Color(0xFFF0F9FF))
                          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent ? const Color(0xFF0284C7) : AppTheme.borderColor(context),
                        width: isCurrent ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(preset.baseCondition.icon, size: 15, color: isCurrent ? const Color(0xFF0284C7) : AppTheme.textSecondary(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                              color: isCurrent ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)) : AppTheme.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${preset.baseTemp.round()}°C',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isCurrent ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)) : AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
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
