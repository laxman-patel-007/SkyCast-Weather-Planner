import 'package:flutter/material.dart';
import 'activity_suggestions_screen.dart';
import 'figma_design_flow_screen.dart';
import 'home_forecast_screen.dart';
import 'hourly_detail_screen.dart';

/// Root navigation shell with Material 3 NavigationBar (Session 9, 12)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeForecastScreen(
        onNavigateToHourly: () => _switchTab(1),
        onNavigateToActivities: () => _switchTab(2),
      ),
      HourlyDetailScreen(
        onNavigateToActivities: () => _switchTab(2),
      ),
      ActivitySuggestionsScreen(
        onNavigateToHourly: () => _switchTab(1),
      ),
      FigmaDesignFlowScreen(
        onNavigateToHome: () => _switchTab(0),
        onNavigateToHourly: () => _switchTab(1),
        onNavigateToActivities: () => _switchTab(2),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule_rounded),
            label: 'Hourly (24h)',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bike_outlined),
            selectedIcon: Icon(Icons.directions_bike_rounded),
            label: 'Activities',
          ),
          NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services_rounded),
            label: 'Figma Flow',
          ),
        ],
      ),
    );
  }
}
