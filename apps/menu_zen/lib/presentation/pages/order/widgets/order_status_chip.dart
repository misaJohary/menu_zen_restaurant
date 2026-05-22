import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class OrderStatusChip extends StatelessWidget {
  final CustomerOrderStatus status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final (label, bg, fg) = switch (status) {
      CustomerOrderStatus.created => (
        l10n.orderStatusCreated,
        AppColors.warning.withValues(alpha: 0.18),
        AppColors.warning,
      ),
      CustomerOrderStatus.inPreparation => (
        l10n.orderStatusInPreparation,
        scheme.primary.withValues(alpha: 0.14),
        scheme.primary,
      ),
      CustomerOrderStatus.ready => (
        l10n.orderStatusReady,
        AppColors.sage.withValues(alpha: 0.18),
        AppColors.sage,
      ),
      CustomerOrderStatus.served => (
        l10n.orderStatusServed,
        AppColors.sage.withValues(alpha: 0.12),
        AppColors.sage,
      ),
      CustomerOrderStatus.cancelled => (
        l10n.orderStatusCancelled,
        scheme.surfaceContainerHighest,
        scheme.onSurface.withValues(alpha: 0.7),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
