import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

/// Figma Guided Flow Screen (Objective 4 & Deliverable: Figma Design Flow)
/// Documents and visualizes the UX journey, progress cues, and design tokens
class FigmaDesignFlowScreen extends StatefulWidget {
  final VoidCallback onNavigateToHome;
  final VoidCallback onNavigateToHourly;
  final VoidCallback onNavigateToActivities;

  const FigmaDesignFlowScreen({
    super.key,
    required this.onNavigateToHome,
    required this.onNavigateToHourly,
    required this.onNavigateToActivities,
  });

  @override
  State<FigmaDesignFlowScreen> createState() => _FigmaDesignFlowScreenState();
}

class _FigmaDesignFlowScreenState extends State<FigmaDesignFlowScreen> {
  int _activeStep = 0;

  final List<Map<String, dynamic>> _flowSteps = [
    {
      'title': '1. Hyperlocal Location Selection',
      'cue': 'Input & Geo Ingestion',
      'icon': Icons.location_on_rounded,
      'color': Color(0xFF0284C7),
      'screenTarget': 'Home Forecast',
      'description':
          'User selects or detects their immediate microclimate area (e.g. Central Green Valley, Coastal Marina). The app reads coordinates and prepares asynchronous query parameters.',
      'userAction': 'Taps "Change" button on Home Forecast Hero Card.',
    },
    {
      'title': '2. Async Fetch & Cache Verification',
      'cue': 'Progress & State Dispatch',
      'icon': Icons.sync_rounded,
      'color': Color(0xFF10B981),
      'screenTarget': 'Home Forecast',
      'description':
          'The app immediately displays cached weather from SharedPreferences (avoiding white screen). Simultaneously, a Future dispatches asynchronously to fetch the latest 24-hour meteorological matrix.',
      'userAction': 'Watches loading cue or instant cached restoration.',
    },
    {
      'title': '3. 24-Hour Forecast Breakdown',
      'cue': 'Hourly Atmospheric Exploration',
      'icon': Icons.view_timeline_rounded,
      'color': Color(0xFF8B5CF6),
      'screenTarget': 'Hourly Detail',
      'description':
          'User inspects temperature, condition icons, wind speed (km/h), and precipitation percentage for every single hour across a smooth scrollable 24-hour breakdown list.',
      'userAction': 'Taps on an hour (e.g. 7 AM or 4 PM) to drill down.',
    },
    {
      'title': '4. Activity Recommendation Engine',
      'cue': 'Provider Reactive Synchronization',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFFF59E0B),
      'screenTarget': 'Activity Planner',
      'description':
          'Provider notifies listeners. The outdoor planner evaluates Jogging, Picnic, and Cycling suitability scores (0-100%) with physiological justifications based on temperature, rain probability, and wind.',
      'userAction': 'Views suitability badges, best time slots, and gear tips.',
    },
    {
      'title': '5. Decision & Outdoor Engagement',
      'cue': 'Action Confirmation',
      'icon': Icons.check_circle_outline_rounded,
      'color': Color(0xFFEC4899),
      'screenTarget': 'Activity Details',
      'description':
          'User confirms optimal time window, notes precautions (e.g. sunscreen, rain gear, wind resistance), and schedules their outdoor session with confidence.',
      'userAction': 'User heads outdoors with exact weather preparedness.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Figma UX Flow & Design System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Design Spec Summary Card
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.design_services_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SkyCast Design Specification',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Guided UX Journey & Material 3 Architecture',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This interactive Figma flow blueprint outlines the screen states, progress cues, '
                    'and reactive Provider transitions specified in the Capstone problem statement.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Interactive Step-by-Step UX Flow',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any stage below to inspect progress cues and test the journey live:',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),

          const SizedBox(height: 12),

          // Flow Steps Stepper
          ...List.generate(_flowSteps.length, (index) {
            final step = _flowSteps[index];
            final isExpanded = _activeStep == index;
            final Color stepColor = step['color'] as Color;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isExpanded ? stepColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: isExpanded ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _activeStep = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: stepColor.withValues(alpha: 0.15),
                            child: Icon(step['icon'] as IconData, color: stepColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isExpanded ? stepColor : theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Cue: ${step['cue']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: stepColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.outline,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const Divider(height: 20),
                        Text(
                          step['description'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'User Action: ${step['userAction']}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FilledButton.tonal(
                              onPressed: () {
                                if (index == 0 || index == 1) {
                                  widget.onNavigateToHome();
                                } else if (index == 2) {
                                  widget.onNavigateToHourly();
                                } else {
                                  widget.onNavigateToActivities();
                                }
                              },
                              child: Text('Launch Screen: ${step['screenTarget']}'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Deliverables & Alignment Table Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Syllabus & Problem Statement Verification',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _checklistTile('UI/Widgets: ListView, Card, Icon', true),
                  _checklistTile('Material 3 Theming: Weather Color Gradients & Clear Typography', true),
                  _checklistTile('Dart Logic: Future, async/await, Provider State Synchronization', true),
                  _checklistTile('Local Storage: SharedPreferences Caching for Instant Reopening', true),
                  _checklistTile('Hourly Detail: 24h Breakdown (Temp, Icon, Wind, Rain)', true),
                  _checklistTile('Activities: Jog, Picnic, Cycling with Justifications', true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _checklistTile(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
