import 'package:design_system/design_system.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ReservationStatusChip extends StatelessWidget {
  final ReservationRequestStatus status;
  const ReservationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final (label, bg, fg) = switch (status) {
      ReservationRequestStatus.waiting => (
        l10n.reservationStatusWaiting,
        AppColors.warning.withValues(alpha: 0.18),
        AppColors.warning,
      ),
      ReservationRequestStatus.accepted => (
        l10n.reservationStatusAccepted,
        AppColors.sage.withValues(alpha: 0.18),
        AppColors.sage,
      ),
      ReservationRequestStatus.refused => (
        l10n.reservationStatusRefused,
        AppColors.error.withValues(alpha: 0.16),
        AppColors.error,
      ),
      ReservationRequestStatus.canceled => (
        l10n.reservationStatusCanceled,
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
