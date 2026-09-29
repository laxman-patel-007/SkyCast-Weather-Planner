import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/weather_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  // Ensure framework services are initialized for asynchronous SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SkyCastApp());
}

/// SkyCast: Hyperlocal Weather & Outdoor Activity Planner App
/// Built strictly following syllabus sessions 1 through 24.
class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'SkyCast Weather & Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
