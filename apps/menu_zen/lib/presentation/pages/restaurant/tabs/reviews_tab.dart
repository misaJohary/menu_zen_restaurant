import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:domain/entities/review_summary_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ReviewsTab extends StatelessWidget {
  final List<ReviewEntity> reviews;
  final ReviewSummaryEntity? summary;

  const ReviewsTab({super.key, required this.reviews, required this.summary});

  @override
  Widget build(BuildContext context) {
    if ((summary == null || summary!.count == 0) && reviews.isEmpty) {
      return const EmptyState(
        icon: PhosphorIconsDuotone.chatCircleText,
        title: 'No reviews yet',
        body: 'Be the first to share your experience.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xxxl,
      ),
      children: [
        if (summary != null) _SummaryHeader(summary: summary!),
        const SizedBox(height: AppSpacing.l),
        ...reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final ReviewSummaryEntity summary;
  const _SummaryHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final total = summary.count;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              summary.avg.toStringAsFixed(1),
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final filled = i < summary.avg.round();
                return Icon(
                  filled
                      ? PhosphorIconsFill.star
                      : PhosphorIconsRegular.star,
                  size: 14,
                  color: filled ? AppColors.warning : scheme.onSurfaceVariant,
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$total ${total == 1 ? 'review' : 'reviews'}',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.l),
        Expanded(
          child: Column(
            children: [
              for (final bucket in [5, 4, 3, 2, 1])
                _HistogramBar(
                  bucket: bucket,
                  count: summary.histogram[bucket] ?? 0,
                  total: total == 0 ? 1 : total,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistogramBar extends StatelessWidget {
  final int bucket;
  final int count;
  final int total;
  const _HistogramBar({
    required this.bucket,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              '$bucket',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor:
                    scheme.onSurface.withValues(alpha: 0.08),
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  const _ReviewCard({required this.review});

  static final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final initial = review.customer.displayName.isEmpty
        ? '·'
        : review.customer.displayName.characters.first.toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: review.customer.avatar != null
                      ? CachedNetworkImage(
                          imageUrl: review.customer.avatar!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _initialAvatar(scheme, initial),
                        )
                      : _initialAvatar(scheme, initial),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customer.displayName.isEmpty
                          ? 'Anonymous'
                          : review.customer.displayName,
                      style: textTheme.titleSmall,
                    ),
                    Text(
                      _dateFormat.format(review.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  final filled = i < review.rating;
                  return Icon(
                    filled
                        ? PhosphorIconsFill.star
                        : PhosphorIconsRegular.star,
                    size: 14,
                    color: filled
                        ? AppColors.warning
                        : scheme.onSurfaceVariant,
                  );
                }),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              review.comment!,
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _initialAvatar(ColorScheme scheme, String initial) {
    return Container(
      color: scheme.tertiary.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: scheme.tertiary,
        ),
      ),
    );
  }
}
