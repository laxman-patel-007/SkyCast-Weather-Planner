import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/hourly_forecast.dart';

/// Hourly Forecast Card widget with modern pill styling,
/// active status indicators, theme-aware colors, and clear typography.
class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast hourly;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isHorizontalCompact;
  final bool isFirst;

  const HourlyForecastCard({
    super.key,
    required this.hourly,
    this.isSelected = false,
    this.onTap,
    this.isHorizontalCompact = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);
    final condition = hourly.condition;

    // Compact Horizontal Glance Card (used on Home Forecast)
    if (isHorizontalCompact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 88,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0369A1).withValues(alpha: 0.35) : theme.colorScheme.primaryContainer)
                : AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : AppTheme.borderColor(context),
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.22),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time label or "NOW" badge
              if (isFirst)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NOW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Text(
                  hourly.formattedHour,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? const Color(0xFF38BDF8) : theme.colorScheme.onPrimaryContainer)
                        : AppTheme.textSecondary(context),
                  ),
                ),

              // Weather Icon with soft ambient badge
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.8))
                      : condition.gradientColors.first.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  condition.icon,
                  color: isDark ? const Color(0xFF38BDF8) : condition.gradientColors.first,
                  size: 24,
                ),
              ),

              // Temperature
              Text(
                hourly.formattedTemp,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? (isDark ? const Color(0xFF38BDF8) : theme.colorScheme.primary)
                      : AppTheme.textPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),

              // Rain likelihood badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hourly.rainChancePct > 20
                      ? (isDark ? const Color(0xFF0369A1).withValues(alpha: 0.28) : const Color(0xFFE0F2FE))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      size: 11,
                      color: hourly.rainChancePct > 20
                          ? const Color(0xFF0284C7)
                          : AppTheme.textSecondary(context),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      hourly.formattedRain,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: hourly.rainChancePct > 20
                            ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                            : AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Full 24-Hour Breakdown Card (used on Hourly Detail screen)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? (isDark ? const Color(0xFF0369A1).withValues(alpha: 0.28) : theme.colorScheme.primaryContainer.withValues(alpha: 0.45))
          : AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : AppTheme.borderColor(context),
          width: isSelected ? 2 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: condition.gradientColors.first.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  condition.icon,
                  color: isDark ? const Color(0xFF38BDF8) : condition.gradientColors.first,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Time and Weather condition description
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hourly.formattedHour,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              fontSize: 15,
                              color: AppTheme.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFirst) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NOW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      condition.displayName,
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Temperature Display
              Expanded(
                flex: 4,
                child: Text(
                  hourly.formattedTemp,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: AppTheme.textPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Wind Speed & Rain Chance Metrics
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Chance of rain badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0369A1).withValues(alpha: 0.28) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop_rounded,
                            size: 12,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            hourly.formattedRain,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Wind speed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.air_rounded, size: 13, color: AppTheme.textSecondary(context)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            hourly.formattedWind,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: AppTheme.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
