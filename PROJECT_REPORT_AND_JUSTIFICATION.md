# SkyCast: Hyperlocal Weather & Outdoor Activity Planner App
## Final Examination Capstone Project Report & Technical Justification

---

### Table of Contents
1. [Executive Summary & Problem Statement](#1-executive-summary--problem-statement)
2. [Syllabus & Course Outcome (CO) Mapping Matrix](#2-syllabus--course-outcome-co-mapping-matrix)
3. [Architecture & Folder Structure](#3-architecture--folder-structure)
4. [State Management Architecture (Provider)](#4-state-management-architecture-provider)
5. [Asynchronous Data Fetching & Concurrency](#5-asynchronous-data-fetching--concurrency)
6. [Local Storage Caching & Offline Fallback Strategy](#6-local-storage-caching--offline-fallback-strategy)
7. [Meteorological Activity Evaluation Engine & Scientific Justifications](#7-meteorological-activity-evaluation-engine--scientific-justifications)
8. [Material 3 Theming & Dynamic Weather Gradients](#8-material-3-theming--dynamic-weather-gradients)
9. [Figma Guided Flow & UX Architecture](#9-figma-guided-flow--ux-architecture)
10. [Automated Testing & Static Analysis](#10-automated-testing--static-analysis)
11. [How to Run the Application](#11-how-to-run-the-application)

---

### 1. Executive Summary & Problem Statement

#### 1.1 Problem Statement
> **SkyCast** is a cross-platform Flutter application designed to provide users with hyperlocal, hourly atmospheric forecasts for their immediate microclimate area and deliver intelligent, condition-based outdoor activity suggestions (**Jogging**, **Picnic**, **Cycling**, etc.). The forecast is fetched asynchronously and cached locally to enable instantaneous app reopening even under intermittent or slow network environments.

#### 1.2 Core Objectives & Fulfillment

| Required Objective | Implementation Details | Status |
| :--- | :--- | :---: |
| **UI/Widgets** | Built **Home Forecast**, **Hourly Detail**, and **Activity Suggestions** screens leveraging `ListView`, `Card`, and `Icon` widgets with responsive constraints. | **100% Complete** |
| **Styling/Theming** | Applied strict **Material 3** theming (`ColorScheme.fromSeed`), dynamic weather-condition gradients (Sunny, Cloudy, Rainy, Windy, etc.), and large crisp temperature typography. | **100% Complete** |
| **Dart Logic** | Utilized null-safe Dart constructs, `Future`, `async/await`, and `try/catch/finally`. Exposed state reactively across all screens using `Provider` (`ChangeNotifierProvider`). | **100% Complete** |
| **Figma Guided Flow** | Formulated a comprehensive guided journey showing progress cues for the user across every touchpoint, alongside an in-app interactive **Figma Design Flow** visualizer. | **100% Complete** |
| **Hourly Detail Metrics** | Explicitly displays **temperature**, **condition icon**, **wind speed (km/h)**, and **chance of rain (%)** for every hour in a 24-hour breakdown. | **100% Complete** |
| **Local Storage Caching** | Implemented persistent cache via `SharedPreferences` that serializes the forecast payload and timestamps, guaranteeing the Home screen is never blank on slow connections. | **100% Complete** |

---

### 2. Syllabus & Course Outcome (CO) Mapping Matrix

This capstone project is implemented strictly within the syllabus curriculum (Sessions 1 through 24):

| Session | Syllabus Topic | Specific SkyCast Implementation | CO Mapping |
| :---: | :--- | :--- | :---: |
| **1-3** | Dev Setup, Git & Cross-Platform Architecture | Flutter 3.x project running across Mobile, Web, and Desktop targets with unified `pubspec.yaml`. | **CO1** |
| **4** | Dart Fundamentals & Null-Safety | Null-safe Dart syntax with sound type enforcement (`??`, `!`, `late`, typed records). | **CO1** |
| **5** | Dart OOP & Collections | Domain models (`HourlyForecast`, `WeatherForecast`, `ActivitySuggestion`, `WeatherCondition`) with typed lists and maps. | **CO2** |
| **6** | Asynchronous Dart | `Future`, `async/await`, and `try/catch/finally` within `WeatherService` and `WeatherProvider`. | **CO1, CO2** |
| **7** | Core Stateless Widgets | `Scaffold`, `AppBar`, `Text`, `Container`, `Row`, `Column`, `CircleAvatar`, `Icon` compositions. | **CO2** |
| **8** | Layout & Responsive Widgets | `Stack`, `Expanded`, `Spacer`, `Padding`, `SizedBox`, `Wrap`, and `MediaQuery` adaptive layouts. | **CO2** |
| **9** | Material 3 & Dynamic Theming | `ColorScheme.fromSeed(seedColor: Color(0xFF0284C7))`, dynamic weather gradients, `FilledButton`, `Card`, `NavigationBar`. | **CO2** |
| **10** | Local UI State & Lifecycle | `StatefulWidget`, `setState`, and clean lifecycle management across tabs. | **CO3** |
| **11** | Provider State Management | `ChangeNotifierProvider`, `Consumer`, and reactive synchronization between forecasts and activity suggestions. | **CO3** |
| **12** | Navigation & Routing | Multi-tab guided flow via Material 3 `NavigationBar` with deep inter-screen navigation. | **CO3** |
| **13** | User Input & Selection | Interactive microclimate zone switcher modal bottom sheet and activity category filters. | **CO3** |
| **14** | Implicit Animations | `AnimatedContainer`, smooth transition effects on selection of hourly cards and tab switches. | **CO3** |
| **16** | Local Storage Persistence | `SharedPreferences` persistence for caching JSON forecast matrices and timestamps. | **CO4** |
| **20** | REST API & JSON Serialization | Manual `toJson()` and `fromJson()` serialization conforming to clean architecture standards. | **CO4** |
| **21** | Unit & Widget Testing | Automated test suites in `test/skycast_test.dart` and `test/widget_test.dart` with 100% pass rate. | **CO5** |
| **22** | Clean Architecture | Separation into domain models, data services, state providers, and presentation widgets. | **CO5** |
| **24** | Capstone Presentation | Comprehensive deliverables, technical justifications, and working prototype. | **CO1-CO5** |

---

### 3. Architecture & Folder Structure

SkyCast adheres to **Feature-and-Layer Clean Architecture** (Session 22):

```
lib/
├── main.dart                          # Application entrypoint & Provider configuration
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 light & dark theme specifications
│   │   └── weather_gradients.dart     # Dynamic atmospheric gradient mapping
│   └── constants/
├── models/
│   ├── weather_condition.dart         # Weather condition enum with icons & gradients
│   ├── hourly_forecast.dart           # Hourly meteorological metrics model & serialization
│   ├── weather_forecast.dart          # 24-hour aggregate weather entity
│   └── activity_suggestion.dart       # Outdoor activity recommendation model with scoring
├── services/
│   ├── weather_service.dart           # Asynchronous data fetcher simulating hyperlocal stations
│   ├── weather_cache_service.dart     # Local storage persistence using SharedPreferences
│   └── activity_planner_service.dart  # Meteorological rule engine for activity justifications
├── providers/
│   └── weather_provider.dart          # Central ChangeNotifier exposing state to all screens
├── screens/
│   ├── main_navigation_screen.dart    # Root shell hosting Material 3 NavigationBar
│   ├── home_forecast_screen.dart      # Hero weather gradient card, 24h glance, top activities
│   ├── hourly_detail_screen.dart      # Scrollable 24-hour breakdown with condition icons
│   ├── activity_suggestions_screen.dart # Detailed outdoor planner with justifications & filters
│   └── figma_design_flow_screen.dart  # Visual UX wireframes, progress cues & design tokens
└── widgets/
    ├── cache_indicator_badge.dart     # Persistent local cache indicator & offline test trigger
    ├── weather_gradient_card.dart     # Hero card with dynamic gradients & crisp typography
    ├── metric_chip.dart               # Modular chip displaying wind, rain, humidity, UV
    ├── hourly_forecast_card.dart      # Reusable hourly card (both compact & list variants)
    ├── activity_card_widget.dart      # Activity card with suitability badge, score & justification
    └── location_selector_sheet.dart   # Hyperlocal microclimate picker modal
```

---

### 4. State Management Architecture (Provider)

The application employs `package:provider` (`ChangeNotifierProvider`) as taught in **Session 11**.

#### Justification for Provider:
1. **Unidirectional Data Flow**: The `WeatherProvider` acts as the single source of truth. UI screens read state via `context.watch<WeatherProvider>()` and trigger actions via `context.read<WeatherProvider>()`.
2. **Automatic Synchronization**: Whenever the forecast updates (via live fetch, location change, or cache load), `_recalculateActivities()` is invoked automatically. This triggers `notifyListeners()`, causing both the **Home Forecast** and **Activity Suggestions** screens to instantly rerender without tight coupling.
3. **Selective Hourly Evaluation**: When the user selects an hour in the **Hourly Detail** screen (`selectHour()`), the state manager re-evaluates all activity suitability scores specifically for that hour's conditions.

```dart
// Snippet from WeatherProvider
void selectHour(HourlyForecast? hour) {
  _selectedHour = hour;
  _recalculateActivities(); // Automatically re-evaluates activities!
  notifyListeners();        // Reactively updates all listening screens
}
```

---

### 5. Asynchronous Data Fetching & Concurrency

As taught in **Session 6** (Async Dart: `Future`, `async/await`, `try/catch/finally`):

1. **Non-Blocking I/O**: Fetching meteorological matrices involves asynchronous network I/O. Dart's single-threaded event loop processes these tasks without freezing the 60fps / 120fps UI rendering pipeline.
2. **Progress Cues**: While the `Future` is executing, `_isLoading` is set to `true`, triggering a clean loading indicator on the Home Forecast screen.
3. **Resilience & Fault Tolerance**: Network calls are wrapped inside `try/catch/finally` blocks. If the live fetch fails or encounters high latency, the app catches the exception and immediately falls back to the locally cached forecast.

---

### 6. Local Storage Caching & Offline Fallback Strategy

As required in **Session 16** (Persistent Data: `SharedPreferences`):

#### 6.1 Cache-Aside Architecture
1. **Cache Read on Boot**: When `WeatherProvider.initialize()` is called, it queries `WeatherCacheService.getCachedForecast()`. If valid cached data exists, it immediately populates the UI state (`_forecast = cached`) before the asynchronous network request finishes.
2. **Zero Empty Screen State**: This satisfies the critical requirement: *"The last fetched forecast is cached locally so the Home screen isn't empty on slow networks."*
3. **Cache Write on Fresh Fetch**: Whenever fresh meteorological data arrives, it is serialized to JSON (`jsonEncode(forecast.toJson())`) and persisted into `SharedPreferences` along with the epoch timestamp.
4. **Visual Indicator Badge**: The user is informed whether the current view is live or served from local cache through the `CacheIndicatorBadge`.

---

### 7. Meteorological Activity Evaluation Engine & Scientific Justifications

The `ActivityPlannerService` implements an objective, physics- and physiology-based algorithm that calculates suitability scores (0–100%) and generates plain-language justifications:

#### 7.1 Jogging & Running
- **Optimal Conditions**: Ambient temperature between **14°C and 21°C**, low precipitation (**< 20%**), wind speeds (**< 20 km/h**).
- **Physical Justification**: At 14°C–21°C, the body achieves optimal thermoregulation with minimal cardiac drift. High heat (> 25°C) triggers electrolyte penalties, while rain (> 50%) introduces asphalt slip hazards.

#### 7.2 Picnic & Social Dining
- **Optimal Conditions**: Ambient temperature between **19°C and 27°C**, rain chance (**< 10%**), wind speeds (**< 15 km/h**).
- **Physical Justification**: Sedentary lawn seating requires mild warmth. Wind speeds exceeding 22 km/h disrupt paper goods and umbrellas, while precipitation > 25% dampens turf and renders blankets unusable.

#### 7.3 Road & Commuter Cycling
- **Optimal Conditions**: Temperature between **16°C and 25°C**, wind speed (**< 18 km/h**), rain (**< 15%**).
- **Physical Justification**: Crosswinds over 28 km/h severely destabilize bicycle handling and front wheel tracking. Wet asphalt reduces tire-to-road friction by up to 35%, increasing braking distance.

#### 7.4 Hiking & Trail Walks
- **Evaluated Factors**: Mud risk from precipitation, UV radiation on exposed ridges, hydration requirements based on temperature.

#### 7.5 Outdoor Landscape Photography
- **Evaluated Factors**: Golden hour timing, cloud diffusion for natural lighting, gear weather-sealing requirements.

---

### 8. Material 3 Theming & Dynamic Weather Gradients

As taught in **Session 9** (Material Design 3 & Theming):
1. **Seed-Based Theming**: Utilizes `ColorScheme.fromSeed(seedColor: Color(0xFF0284C7))` to dynamically generate harmonious tonal palettes conforming to Material 3 specifications.
2. **Weather-Condition Gradients**:
   - **Sunny**: Warm sunrise orange (`#FF7E40`) to crisp cyan blue (`#4A90E2`).
   - **Partly Cloudy**: Atmospheric sky blue (`#3A7BD5`) to soft teal (`#4CA1AF`).
   - **Cloudy / Overcast**: Slate grey (`#536976`) to deep indigo (`#292E49`).
   - **Rainy**: Deep navy slate (`#2C3E50`) to marine blue (`#3498DB`).
   - **Windy**: Airy azure (`#00B4DB`) to deep wind-stream blue (`#1E3C72`).
   - **Clear Night**: Celestial charcoal (`#0F2027`) to twilight cyan (`#2C5364`).
3. **Typography**: High-contrast, large temperature displays (68pt bold, negative letter-spacing) paired with semantic condition badges.

---

### 9. Figma Guided Flow & UX Architecture

The **Figma Design Flow** tab (and in-app interactive visualizer) models the 5-stage user journey with clear progress cues:

```
[1. Location Selection] ──► [2. Async Fetch & Cache Check] ──► [3. Hourly Breakdown (24h)]
                                                                           │
                                                                           ▼
[5. Action & Gear Prep] ◄── [4. Reactive Activity Suitability Engine] ◄────┘
```

1. **Location Selection**: User chooses a hyperlocal microclimate zone.
2. **Async Fetch & Cache Check**: Instantaneous cache restoration cue followed by asynchronous refresh.
3. **24-Hour Breakdown**: Detailed inspection of temperature, condition icons, wind speed, and rain probability.
4. **Reactive Activity Engine**: Instant evaluation of outdoor suitability scores and justifications.
5. **Action & Confirmation**: User chooses the optimal time slot and packs recommended gear.

---

### 10. Automated Testing & Static Analysis

Conforming to **Session 21** (Unit and Widget Testing):

- **Unit Tests (`test/skycast_test.dart`)**:
  - `WeatherCondition` parsing and serialization.
  - `HourlyForecast` JSON encoding/decoding.
  - `WeatherForecast` immutable `copyWith` verification.
  - `ActivityPlannerService` scoring accuracy for Jogging, Picnic, and Cycling under varying meteorological constraints.
- **Widget Tests (`test/widget_test.dart`)**:
  - `SkyCastApp` root widget composition.
  - Verification of `NavigationBar` destinations (Home, Hourly, Activities, Figma Flow).
  - Validation of asynchronous state rendering.
- **Static Analysis**: Verified with `dart analyze` — **0 issues found**.
- **Test Result**: **7/7 tests passed successfully** (`flutter test`).

---

### 11. How to Run the Application

```bash
# 1. Navigate to the project root directory
cd /Users/laxmanpatel/Desktop/Futter

# 2. Run static analysis to verify zero errors
dart analyze

# 3. Execute all unit and widget tests
flutter test

# 4. Launch the application on macOS or Chrome Web
flutter run -d macos
# OR
flutter run -d chrome
```
