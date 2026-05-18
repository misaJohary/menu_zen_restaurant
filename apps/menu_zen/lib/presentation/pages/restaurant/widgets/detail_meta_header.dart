import 'package:design_system/design_system.dart';
import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/generated/app_localizations.dart';

class DetailMetaHeader extends StatelessWidget {
  final RestaurantDetailPublicEntity detail;
  const DetailMetaHeader({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.7);

    final metaParts = <String>[];
    final type = restaurantTypeLabel(context, detail.type?.name);
    if (type.isNotEmpty) metaParts.add(type);
    if (detail.city.isNotEmpty) metaParts.add(detail.city);
    final distance = formatDistanceKm(context, detail.distanceKm);
    if (distance != null) metaParts.add(distance);

    final statusInfo = _statusFor(context, detail);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.name, style: textTheme.displaySmall),
          if (metaParts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              metaParts.join(' · '),
              style: textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (statusInfo != null)
                StatusPill(status: statusInfo.status, label: statusInfo.label),
              if (detail.reviewCount > 0 || (detail.avgRating ?? 0) > 0)
                _RatingChip(
                  rating: detail.avgRating ?? 0,
                  count: detail.reviewCount,
                ),
            ],
          ),
          if (detail.description != null &&
              detail.description!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              detail.description!,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  OpenStatusInfo? _statusFor(
    BuildContext context,
    RestaurantDetailPublicEntity detail,
  ) {
    final l10n = AppLocalizations.of(context);
    if (detail.isOpenNow) {
      final fromHours = resolveOpenStatus(context, detail.openingHours);
      if (fromHours != null) return fromHours;
      return OpenStatusInfo(OpenStatus.open, l10n.detailStatusOpen);
    }
    final next = detail.nextOpening;
    if (next != null) {
      return OpenStatusInfo(
        OpenStatus.closed,
        l10n.detailStatusClosedOpensAt(next.day, next.time),
      );
    }
    return OpenStatusInfo(OpenStatus.closed, l10n.detailStatusClosed);
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  final int count;

  const _RatingChip({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            PhosphorIconsFill.star,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            rating > 0 ? rating.toStringAsFixed(1) : '–',
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($count)',
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
