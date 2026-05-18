import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:domain/entities/review_summary_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/navigation/route_paths.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/restaurant_detail/restaurant_detail_cubit.dart';
import '../widgets/review_composer_sheet.dart';

class ReviewsTab extends StatelessWidget {
  final int restaurantId;
  final String restaurantName;
  final List<ReviewEntity> reviews;
  final ReviewSummaryEntity? summary;

  const ReviewsTab({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.reviews,
    required this.summary,
  });

  ReviewEntity? _findMyReview(int? customerId) {
    if (customerId == null) return null;
    for (final review in reviews) {
      if (review.customer.id == customerId) return review;
    }
    return null;
  }

  Future<void> _openComposer(
    BuildContext context, {
    ReviewEntity? existing,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (context.read<AuthBloc>().state is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewSignInSnack)),
      );
      await context.push(RoutePaths.authLogin);
      if (!context.mounted) return;
      if (context.read<AuthBloc>().state is! AuthAuthenticated) return;
    }

    final result = await showModalBottomSheet<ReviewComposerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewComposerSheet(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        existing: existing,
      ),
    );

    if (result == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (result.saved != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? l10n.reviewPostedSnack
                : l10n.reviewUpdatedSnack,
          ),
        ),
      );
    } else if (result.deletedId != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reviewDeletedSnack)),
      );
    }

    if (!context.mounted) return;
    await context
        .read<RestaurantDetailCubit>()
        .refreshReviews(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final customerId = authState is AuthAuthenticated
            ? authState.customer.id
            : null;
        final myReview = _findMyReview(customerId);
        final hasContent =
            (summary != null && summary!.count > 0) || reviews.isNotEmpty;

        return Stack(
          children: [
            if (!hasContent)
              EmptyState(
                icon: PhosphorIconsDuotone.chatCircleText,
                title: l10n.reviewsEmptyTitle,
                body: l10n.reviewsEmptyBody,
                actionLabel: l10n.reviewsEmptyAction,
                onAction: () => _openComposer(context),
              )
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.xxxl + AppSpacing.xxl,
                ),
                children: [
                  if (summary != null) _SummaryHeader(summary: summary!),
                  const SizedBox(height: AppSpacing.l),
                  _WriteReviewCard(
                    hasReview: myReview != null,
                    onTap: () => _openComposer(context, existing: myReview),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  ...reviews.map(
                    (r) => _ReviewCard(
                      review: r,
                      isMine: r.customer.id == customerId,
                      onEdit: r.customer.id == customerId
                          ? () => _openComposer(context, existing: r)
                          : null,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _WriteReviewCard extends StatelessWidget {
  final bool hasReview;
  final VoidCallback onTap;

  const _WriteReviewCard({required this.hasReview, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(
                hasReview
                    ? PhosphorIconsDuotone.pencilSimpleLine
                    : PhosphorIconsDuotone.star,
                size: 28,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasReview
                          ? l10n.reviewWriteEditTitle
                          : l10n.reviewWriteCreateTitle,
                      style: textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasReview
                          ? l10n.reviewWriteEditSubtitle
                          : l10n.reviewWriteCreateSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(PhosphorIconsRegular.caretRight, size: 18),
            ],
          ),
        ),
      ),
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
              AppLocalizations.of(context).reviewsCount(total),
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
  final bool isMine;
  final VoidCallback? onEdit;

  const _ReviewCard({
    required this.review,
    required this.isMine,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('MMM d, yyyy', localeTag);
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.customer.displayName.isEmpty
                                ? l10n.commonAnonymous
                                : review.customer.displayName,
                            style: textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  scheme.primary.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              l10n.commonYou,
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      dateFormat.format(review.createdAt),
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
              if (isMine && onEdit != null)
                IconButton(
                  tooltip: l10n.commonEdit,
                  iconSize: 18,
                  onPressed: onEdit,
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
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
