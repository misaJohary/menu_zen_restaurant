import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

enum OpenStatus { open, closingSoon, closed }

/// Small pill with a colored dot + label. Shape changes with state too
/// (not color-only) — per design §3.2 a11y rule.
class StatusPill extends StatelessWidget {
  final OpenStatus status;
  final String label;

  const StatusPill({super.key, required this.status, required this.label});

  Color get _color {
    switch (status) {
      case OpenStatus.open:
        return AppColors.sage;
      case OpenStatus.closingSoon:
        return AppColors.warning;
      case OpenStatus.closed:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (status) {
      case OpenStatus.open:
        return Icons.circle;
      case OpenStatus.closingSoon:
        return Icons.access_time_filled;
      case OpenStatus.closed:
        return Icons.do_not_disturb_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 8, color: _color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}
