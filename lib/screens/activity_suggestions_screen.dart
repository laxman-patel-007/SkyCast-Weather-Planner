import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/activity_suggestion.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/activity_card_widget.dart';

/// Activity Suggestions Screen
/// Automatically updates via Provider when forecast changes or when an hour is selected.
class ActivitySuggestionsScreen extends StatefulWidget {
  final VoidCallback onNavigateToHourly;
  final bool isDesktopWeb;

  const ActivitySuggestionsScreen({
    super.key,
    required this.onNavigateToHourly,
    this.isDesktopWeb = false,
  });

  @override
  State<ActivitySuggestionsScreen> createState() => _ActivitySuggestionsScreenState();
}

class _ActivitySuggestionsScreenState extends State<ActivitySuggestionsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Cardio & Fitness',
    'Leisure & Family',
    'Active Transit & Sport',
    'Outdoor Adventure',
    'Water & Aquatics',
    'Night & Astronomy',
    'Wellness & Mindfulness',
    'Creative Arts',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final forecast = provider.forecast;
    final selectedHour = provider.selectedHour;
    final isDark = AppTheme.isDark(context);

    if (forecast == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity Planner')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final activities = provider.activities.where((act) {
      if (_selectedCategory == 'All') return true;
      return act.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: widget.isDesktopWeb
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Activity Planner',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.5,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    forecast.locationName,
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) => IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: AppTheme.textSecondary(context),
                    ),
                    tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    onPressed: () => themeProvider.toggleTheme(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.schedule_rounded, color: AppTheme.textSecondary(context)),
                  tooltip: 'View Hourly Forecast',
                  onPressed: widget.onNavigateToHourly,
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: AppTheme.textSecondary(context)),
                  tooltip: 'Refresh',
                  onPressed: () => provider.refresh(),
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
              child: Column(
                children: [
                  // Hourly Context Banner (Shows if evaluating current conditions vs selected hour)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedHour != null
                          ? (isDark ? const Color(0xFF0369A1).withValues(alpha: 0.22) : const Color(0xFFF0F9FF))
                          : AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selectedHour != null ? const Color(0xFF0284C7) : AppTheme.borderColor(context),
                        width: selectedHour != null ? 1.6 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedHour != null
                              ? const Color(0xFF0284C7).withValues(alpha: 0.10)
                              : Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedHour != null
                                ? const Color(0xFF0284C7).withValues(alpha: 0.16)
                                : AppTheme.subtleBg(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            selectedHour != null ? Icons.timelapse_rounded : Icons.radar_rounded,
                            color: selectedHour != null ? const Color(0xFF0284C7) : AppTheme.textSecondary(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedHour != null
                                    ? 'Evaluating Slot: ${selectedHour.formattedFullTime}'
                                    : 'Evaluating Current Microclimate',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: selectedHour != null ? const Color(0xFF0284C7) : AppTheme.textPrimary(context),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedHour != null
                                    ? '${selectedHour.formattedTemp} • ${selectedHour.condition.displayName} • Wind ${selectedHour.formattedWind} • Rain ${selectedHour.formattedRain}'
                                    : '${forecast.currentTemp.round()}°C • Wind ${forecast.currentWindSpeed.round()} km/h • Rain ${forecast.currentRainChance}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary(context),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (selectedHour != null)
                          TextButton(
                            onPressed: () => provider.selectHour(null),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              backgroundColor: isDark
                                  ? const Color(0xFF0369A1).withValues(alpha: 0.35)
                                  : const Color(0xFFE0F2FE),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Horizontal Category Filter Chips
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(cat),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF0284C7) : AppTheme.textSecondary(context),
                            ),
                            backgroundColor: AppTheme.cardColor(context),
                            selectedColor: isDark
                                ? const Color(0xFF0284C7).withValues(alpha: 0.28)
                                : const Color(0xFFE0F2FE),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF0284C7) : AppTheme.borderColor(context),
                              width: isSelected ? 1.6 : 1.0,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Activities Area
                  Expanded(
                    child: activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_alt_off_rounded, size: 48, color: AppTheme.textSecondary(context)),
                                const SizedBox(height: 12),
                                Text(
                                  'No activities match "$_selectedCategory"',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = 'All';
                                    });
                                  },
                                  child: const Text('Show All Activities'),
                                ),
                              ],
                            ),
                          )
                        : isWide
                            ? _buildDesktopActivityGrid(activities)
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 4, bottom: 24),
                                itemCount: activities.length,
                                itemBuilder: (context, index) {
                                  return ActivityCardWidget(
                                    activity: activities[index],
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

  Widget _buildDesktopActivityGrid(List<ActivitySuggestion> activities) {
    final leftCol = <ActivitySuggestion>[];
    final rightCol = <ActivitySuggestion>[];

    for (int i = 0; i < activities.length; i++) {
      if (i.isEven) {
        leftCol.add(activities[i]);
      } else {
        rightCol.add(activities[i]);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: leftCol.map((a) => ActivityCardWidget(activity: a)).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: rightCol.map((a) => ActivityCardWidget(activity: a)).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
