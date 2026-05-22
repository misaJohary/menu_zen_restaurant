import 'package:design_system/design_system.dart';
import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/generated/app_localizations.dart';
import 'reservation_status_chip.dart';

class ReservationCard extends StatelessWidget {
  final CustomerReservationEntity reservation;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.yMMMEd(localeTag).add_jm();

    final restaurant = reservation.restaurant;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: restaurant.logo != null
                      ? Image.network(
                          restaurant.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _Initial(name: restaurant.name),
                        )
                      : _Initial(name: restaurant.name),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        ReservationStatusChip(status: reservation.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.calendar,
                          size: 14,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            dateLabel.format(reservation.reservedAt.toLocal()),
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (reservation.partySize != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.users,
                            size: 14,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.reserveGuests(reservation.partySize!),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    if ((reservation.note ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        reservation.note!,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
      ),
    );
  }
}
