import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/di/dependencies_injection.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bloc/reservation_detail/reservation_detail_cubit.dart';
import 'widgets/reservation_status_chip.dart';

class ReservationDetailPage extends StatelessWidget {
  final int reservationId;
  final CustomerReservationEntity? initial;

  const ReservationDetailPage({
    super.key,
    required this.reservationId,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ReservationDetailCubit>();
        if (initial != null) {
          cubit.seed(initial!);
        } else {
          cubit.load(reservationId);
        }
        return cubit;
      },
      child: _ReservationDetailView(reservationId: reservationId),
    );
  }
}

class _ReservationDetailView extends StatelessWidget {
  final int reservationId;
  const _ReservationDetailView({required this.reservationId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservationDetailTitle)),
      body: SafeArea(
        child: BlocConsumer<ReservationDetailCubit, ReservationDetailState>(
          listenWhen: (prev, curr) =>
              curr is ReservationDetailLoaded &&
              curr.lastErrorMessage != null &&
              (prev is! ReservationDetailLoaded ||
                  prev.lastErrorMessage != curr.lastErrorMessage),
          listener: (context, state) {
            final message = (state as ReservationDetailLoaded).lastErrorMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) => switch (state) {
            ReservationDetailInitial() ||
            ReservationDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ReservationDetailError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<ReservationDetailCubit>().load(
                reservationId,
              ),
            ),
            ReservationDetailCancelling(:final reservation) => _DetailBody(
              reservation: reservation,
              cancelling: true,
            ),
            ReservationDetailLoaded(:final reservation) => _DetailBody(
              reservation: reservation,
              cancelling: false,
            ),
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final CustomerReservationEntity reservation;
  final bool cancelling;
  const _DetailBody({required this.reservation, required this.cancelling});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.yMMMMEEEEd(localeTag);
    final timeLabel = DateFormat.jm(localeTag);
    final createdAtLabel = DateFormat.yMMMd(localeTag).add_jm();

    final restaurant = reservation.restaurant;
    final canCancel = reservation.status.canCancel;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(restaurant.name, style: textTheme.headlineSmall),
            ),
            ReservationStatusChip(status: reservation.status),
          ],
        ),
        if (restaurant.city.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            restaurant.city,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _DetailRow(
          icon: PhosphorIconsRegular.calendar,
          label: l10n.reservationDateLabel,
          value: dateLabel.format(reservation.reservedAt.toLocal()),
        ),
        const SizedBox(height: AppSpacing.m),
        _DetailRow(
          icon: PhosphorIconsRegular.clock,
          label: l10n.reservationTimeLabel,
          value: timeLabel.format(reservation.reservedAt.toLocal()),
        ),
        if (reservation.partySize != null) ...[
          const SizedBox(height: AppSpacing.m),
          _DetailRow(
            icon: PhosphorIconsRegular.users,
            label: l10n.reservationPartySizeLabel,
            value: l10n.reserveGuests(reservation.partySize!),
          ),
        ],
        if ((reservation.note ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          _DetailRow(
            icon: PhosphorIconsRegular.notepad,
            label: l10n.reservationNoteLabel,
            value: reservation.note!,
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        _DetailRow(
          icon: PhosphorIconsRegular.paperPlane,
          label: l10n.reservationRequestedAt,
          value: createdAtLabel.format(reservation.createdAt.toLocal()),
        ),
        if (reservation.assignedTables.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsRegular.armchair, color: AppColors.sage),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    l10n.reservationTablesAssigned(
                      reservation.assignedTables.length,
                    ),
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (reservation.status == ReservationRequestStatus.refused) ...[
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(PhosphorIconsRegular.xCircle,
                    color: AppColors.error),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    l10n.reservationRefusedBanner,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (canCancel) ...[
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: cancelling
                ? null
                : () => _confirmCancel(context),
            icon: const Icon(PhosphorIconsRegular.xCircle),
            label: cancelling
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.reservationCancel),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ReservationDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reservationCancelDialogTitle),
        content: Text(l10n.reservationCancelDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonKeep),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.reservationCancel),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.cancel();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: PhosphorIconsDuotone.wifiSlash,
      title: l10n.commonReachKitchenError,
      body: message,
      actionLabel: l10n.commonTryAgain,
      onAction: onRetry,
    );
  }
}
