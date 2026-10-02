import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/weather_service.dart';

/// Modal bottom sheet allowing users to switch hyperlocal weather zones
class LocationSelectorSheet extends StatelessWidget {
  final String currentPresetId;
  final ValueChanged<String> onSelected;

  const LocationSelectorSheet({
    super.key,
    required this.currentPresetId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Hyperlocal Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Switch microclimates to see weather and outdoor activities update dynamically.',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: WeatherService.availablePresets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final preset = WeatherService.availablePresets[index];
                  final isSelected = preset.id == currentPresetId;
                  final condition = preset.baseCondition;

                  return Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: isSelected
                        ? (isDark ? const Color(0xFF0369A1).withValues(alpha: 0.3) : const Color(0xFFF0F9FF))
                        : (isDark ? const Color(0xFF0F172A) : Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : AppTheme.borderColor(context),
                        width: isSelected ? 2 : 1.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        onSelected(preset.id);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: condition.gradientColors.first.withValues(alpha: isDark ? 0.22 : 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                condition.icon,
                                color: isDark ? const Color(0xFF38BDF8) : condition.gradientColors.first,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.textPrimary(context),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    preset.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _miniTag(context, '${preset.baseTemp}°C', Icons.thermostat_rounded),
                                      const SizedBox(width: 6),
                                      _miniTag(context, 'Rain ${preset.baseRain}%', Icons.water_drop_rounded),
                                      const SizedBox(width: 6),
                                      _miniTag(context, '${preset.baseWind} km/h', Icons.air_rounded),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF0284C7),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniTag(BuildContext context, String text, IconData icon) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderColor(context), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppTheme.textSecondary(context)),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
