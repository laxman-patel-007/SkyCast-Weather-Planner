import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';

/// Top Desktop Web Header
/// Renders a modern SaaS-style navigation bar for wide web viewports with Light/Dark mode toggle
class DesktopWebHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;

  const DesktopWebHeader({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = AppTheme.isDark(context);

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor(context), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          // Brand Logo & Title
          InkWell(
            onTap: () => onSelectTab(0),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SkyCast',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.6,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor(context)),
                    ),
                    child: Text(
                      'Hyperlocal Forecast & Planner',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 32),

          // Central Navigation Tabs (Home, Hourly (24h), Activities)
          Expanded(
            child: Row(
              children: [
                _navPill(
                  context: context,
                  index: 0,
                  label: 'Home',
                  icon: Icons.wb_sunny_rounded,
                  isSelected: selectedIndex == 0,
                ),
                const SizedBox(width: 6),
                _navPill(
                  context: context,
                  index: 1,
                  label: 'Hourly (24h)',
                  icon: Icons.schedule_rounded,
                  isSelected: selectedIndex == 1,
                ),
                const SizedBox(width: 6),
                _navPill(
                  context: context,
                  index: 2,
                  label: 'Activities',
                  icon: Icons.directions_bike_rounded,
                  isSelected: selectedIndex == 2,
                ),
              ],
            ),
          ),

          // Right Actions: Theme Switcher & Refresh

          // Theme Mode Toggle Button
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 16,
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
              ),
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: 4),

          // Refresh Button
          IconButton(
            tooltip: 'Refresh Forecast',
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
            onPressed: provider.isLoading ? null : () => provider.refresh(),
          ),
        ],
      ),
    );
  }

  Widget _navPill({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = AppTheme.isDark(context);

    return InkWell(
      onTap: () => onSelectTab(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0284C7).withValues(alpha: 0.28) : const Color(0xFFE0F2FE))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                  : AppTheme.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                    : AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
