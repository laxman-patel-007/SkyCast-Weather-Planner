import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/activity_card_widget.dart';

/// Activity Suggestions Screen (Objectives 1, 3, 4)
/// Automatically updates via Provider when forecast changes or when an hour is selected.
class ActivitySuggestionsScreen extends StatefulWidget {
  final VoidCallback onNavigateToHourly;

  const ActivitySuggestionsScreen({
    super.key,
    required this.onNavigateToHourly,
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
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();
    final forecast = provider.forecast;
    final selectedHour = provider.selectedHour;

    if (forecast == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Outdoor Activity Planner')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final activities = provider.activities.where((act) {
      if (_selectedCategory == 'All') return true;
      return act.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Outdoor Activity Planner'),
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
            icon: const Icon(Icons.schedule_rounded),
            tooltip: 'View Hourly Forecast',
            onPressed: widget.onNavigateToHourly,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hourly Context Banner (Shows if evaluating current conditions vs selected hour)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selectedHour != null
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedHour != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedHour != null ? Icons.timelapse_rounded : Icons.radar_rounded,
                  color: selectedHour != null ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedHour != null
                            ? 'Evaluating Hourly Slot: ${selectedHour.formattedFullTime}'
                            : 'Evaluating Current Microclimate',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selectedHour != null
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        selectedHour != null
                            ? '${selectedHour.formattedTemp} • ${selectedHour.condition.displayName} • Wind ${selectedHour.formattedWind} • Rain ${selectedHour.formattedRain}'
                            : '${forecast.currentTemp.round()}°C • Wind ${forecast.currentWindSpeed.round()} km/h • Rain ${forecast.currentRainChance}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedHour != null)
                  TextButton(
                    onPressed: () => provider.selectHour(null),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Category Filter Chips (Session 8, 9)
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

          // List of Activity Cards (Session 7, 8, 9)
          Expanded(
            child: activities.isEmpty
                ? Center(
                    child: Text(
                      'No activities found for this filter.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ActivityCardWidget(activity: activity);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
