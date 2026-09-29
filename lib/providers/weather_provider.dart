import 'package:flutter/foundation.dart';
import '../models/activity_suggestion.dart';
import '../models/hourly_forecast.dart';
import '../models/weather_forecast.dart';
import '../services/activity_planner_service.dart';
import '../services/weather_cache_service.dart';
import '../services/weather_service.dart';

/// Central state manager using Provider (Session 11)
/// Exposes reactive forecast, hourly selection, and outdoor activity recommendations
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final WeatherCacheService _cacheService;
  final ActivityPlannerService _activityPlannerService;

  WeatherProvider({
    WeatherService? weatherService,
    WeatherCacheService? cacheService,
    ActivityPlannerService? activityPlannerService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _cacheService = cacheService ?? WeatherCacheService(),
        _activityPlannerService = activityPlannerService ?? ActivityPlannerService();

  WeatherForecast? _forecast;
  List<ActivitySuggestion> _activities = [];
  HourlyForecast? _selectedHour;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;
  DateTime? _lastCachedTimestamp;
  String _currentPresetId = 'central_park';

  // Getters
  WeatherForecast? get forecast => _forecast;
  List<ActivitySuggestion> get activities => _activities;
  HourlyForecast? get selectedHour => _selectedHour;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineMode => _isOfflineMode;
  DateTime? get lastCachedTimestamp => _lastCachedTimestamp;
  String get currentPresetId => _currentPresetId;

  /// Bootstrap the provider: load cache first, then fetch live asynchronously
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // 1. Attempt instantaneous local storage restoration (Session 16)
    try {
      final cached = await _cacheService.getCachedForecast();
      _lastCachedTimestamp = await _cacheService.getLastCachedTimestamp();

      if (cached != null) {
        _forecast = cached;
        _activities = _activityPlannerService.evaluateActivities(forecast: cached);
        // Notify immediately so UI renders without delay on slow networks
        notifyListeners();
      }
    } catch (_) {
      // Continue to live fetch even if cache reading fails
    }

    // 2. Fetch fresh forecast asynchronously via Future & async/await (Session 6)
    await fetchForecast(presetId: _currentPresetId);
  }

  /// Asynchronously fetches forecast with error recovery and persistence
  Future<void> fetchForecast({
    String? presetId,
    bool simulateError = false,
  }) async {
    if (presetId != null) {
      _currentPresetId = presetId;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final freshForecast = await _weatherService.fetchForecast(
        presetId: _currentPresetId,
        simulateNetworkError: simulateError,
      );

      _forecast = freshForecast;
      _isOfflineMode = false;

      // Update cache in background
      await _cacheService.cacheForecast(freshForecast);
      _lastCachedTimestamp = DateTime.now();

      // Recalculate activities automatically (Objective 2)
      _recalculateActivities();
    } catch (e) {
      // If network fails, attempt cache fallback
      final cached = await _cacheService.getCachedForecast();
      if (cached != null) {
        _forecast = cached;
        _isOfflineMode = true;
        _errorMessage = 'Using cached forecast: Network connection unavailable.';
        _recalculateActivities();
      } else {
        _errorMessage = 'Unable to fetch weather forecast: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh handler
  Future<void> refresh() async {
    await fetchForecast(presetId: _currentPresetId);
  }

  /// Select a specific hourly slot to view its custom outdoor activity suitability
  void selectHour(HourlyForecast? hour) {
    _selectedHour = hour;
    _recalculateActivities();
    notifyListeners();
  }

  /// Select location preset
  Future<void> setLocation(String presetId) async {
    _selectedHour = null;
    await fetchForecast(presetId: presetId);
  }

  /// Toggle simulated offline state to demonstrate caching behavior
  Future<void> testOfflineSimulation() async {
    await fetchForecast(presetId: _currentPresetId, simulateError: true);
  }

  /// Private helper to synchronize activity evaluations whenever forecast updates
  void _recalculateActivities() {
    if (_forecast == null) {
      _activities = [];
      return;
    }

    _activities = _activityPlannerService.evaluateActivities(
      forecast: _forecast!,
      selectedHour: _selectedHour,
    );
  }
}
