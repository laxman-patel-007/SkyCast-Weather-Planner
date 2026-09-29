import 'package:flutter/material.dart';

/// Rating level for outdoor suitability
enum SuitabilityLevel {
  ideal,
  good,
  moderate,
  caution,
  notRecommended;

  String get label {
    switch (this) {
      case SuitabilityLevel.ideal:
        return 'Ideal Condition';
      case SuitabilityLevel.good:
        return 'Good to Go';
      case SuitabilityLevel.moderate:
        return 'Moderate';
      case SuitabilityLevel.caution:
        return 'Caution Advised';
      case SuitabilityLevel.notRecommended:
        return 'Not Recommended';
    }
  }

  Color get color {
    switch (this) {
      case SuitabilityLevel.ideal:
        return const Color(0xFF10B981); // Emerald green
      case SuitabilityLevel.good:
        return const Color(0xFF06B6D4); // Cyan blue
      case SuitabilityLevel.moderate:
        return const Color(0xFFF59E0B); // Amber
      case SuitabilityLevel.caution:
        return const Color(0xFFF97316); // Orange
      case SuitabilityLevel.notRecommended:
        return const Color(0xFFEF4444); // Crimson red
    }
  }

  IconData get icon {
    switch (this) {
      case SuitabilityLevel.ideal:
        return Icons.check_circle_rounded;
      case SuitabilityLevel.good:
        return Icons.thumb_up_alt_rounded;
      case SuitabilityLevel.moderate:
        return Icons.info_outline_rounded;
      case SuitabilityLevel.caution:
        return Icons.warning_amber_rounded;
      case SuitabilityLevel.notRecommended:
        return Icons.cancel_outlined;
    }
  }
}

/// Represents an activity suggestion with meteorological justification
class ActivitySuggestion {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final SuitabilityLevel suitability;
  final int score; // 0 - 100
  final String justification;
  final String bestTimeWindow;
  final List<String> tips;
  final String idealTempRange;
  final String windTolerance;
  final String rainTolerance;

  const ActivitySuggestion({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.suitability,
    required this.score,
    required this.justification,
    required this.bestTimeWindow,
    required this.tips,
    required this.idealTempRange,
    required this.windTolerance,
    required this.rainTolerance,
  });
}
