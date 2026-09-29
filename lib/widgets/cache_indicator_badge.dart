import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Visual badge showing local storage caching status (Session 16)
class CacheIndicatorBadge extends StatelessWidget {
  final bool isFromCache;
  final DateTime? lastCachedTimestamp;
  final VoidCallback onRefresh;
  final VoidCallback? onSimulateOffline;

  const CacheIndicatorBadge({
    super.key,
    required this.isFromCache,
    required this.lastCachedTimestamp,
    required this.onRefresh,
    this.onSimulateOffline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = lastCachedTimestamp != null
        ? DateFormat('h:mm a').format(lastCachedTimestamp!)
        : 'Just now';

    if (isFromCache) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.offline_bolt_rounded, color: Color(0xFFD97706), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Offline Mode: Cached at $timeStr',
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD97706), size: 18),
              onPressed: onRefresh,
              tooltip: 'Retry Live Fetch',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 8),
              Text(
                'Live Hyperlocal • Cached locally at $timeStr',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (onSimulateOffline != null)
            InkWell(
              onTap: onSimulateOffline,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Test Cache',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
