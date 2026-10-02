import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/desktop_web_header.dart';
import 'activity_suggestions_screen.dart';
import 'home_forecast_screen.dart';
import 'hourly_detail_screen.dart';

/// Root navigation shell with responsive Desktop Web Header and Material 3 NavigationBar
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
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 960 && (mediaQuery.size.width > mediaQuery.size.height || kIsWeb);

    final List<Widget> screens = [
      HomeForecastScreen(
        onNavigateToHourly: () => _switchTab(1),
        onNavigateToActivities: () => _switchTab(2),
        isDesktopWeb: isDesktop,
      ),
      HourlyDetailScreen(
        onNavigateToActivities: () => _switchTab(2),
        isDesktopWeb: isDesktop,
      ),
      ActivitySuggestionsScreen(
        onNavigateToHourly: () => _switchTab(1),
        isDesktopWeb: isDesktop,
      ),
    ];

    final navBar = NavigationBar(
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
      ],
    );

    return Scaffold(
      appBar: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: DesktopWebHeader(
                selectedIndex: _currentIndex,
                onSelectTab: _switchTab,
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: isDesktop
          ? Offstage(offstage: true, child: navBar)
          : navBar,
    );
  }
}
