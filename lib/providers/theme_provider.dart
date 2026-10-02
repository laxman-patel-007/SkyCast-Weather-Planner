import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing Light and Dark theme modes with SharedPreferences persistence
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'skycast_theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  Future<void>? _initFuture;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _initFuture = _loadThemePreference();
  }

  Future<void> init() async {
    await (_initFuture ??= _loadThemePreference());
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_prefKey);
      if (modeStr == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {
      _themeMode = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    await init();
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
    await _saveThemePreference();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await init();
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _saveThemePreference();
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_themeMode == ThemeMode.dark) {
        await prefs.setString(_prefKey, 'dark');
      } else {
        await prefs.setString(_prefKey, 'light');
      }
    } catch (_) {}
  }
}
