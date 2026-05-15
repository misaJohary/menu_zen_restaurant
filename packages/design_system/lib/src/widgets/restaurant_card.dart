import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import 'restaurant_cover.dart';
import 'status_pill.dart';

/// Visual variants of [RestaurantCard].
enum RestaurantCardVariant { wide, compact, editorial, horizontal }

/// Card used in Discover rails and Search results.
///
/// All copy is passed in by the caller — this widget knows nothing about
/// the restaurant entity, so it stays in the design system package.
class RestaurantCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? coverUrl;
  final String? distanceLabel;
  final String? priceLabel;
  final OpenStatus? openStatus;
  final String? openStatusLabel;
  final VoidCallback? onTap;
  final RestaurantCardVariant variant;

  const RestaurantCard({
    super.key,
    required this.name,
    this.subtitle,
    this.coverUrl,
    this.distanceLabel,
    this.priceLabel,
    this.openStatus,
    this.openStatusLabel,
    this.onTap,
    this.variant = RestaurantCardVariant.wide,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case RestaurantCardVariant.wide:
        return _WideCard(card: this);
      case RestaurantCardVariant.compact:
        return _CompactCard(card: this);
      case RestaurantCardVariant.editorial:
        return _EditorialCard(card: this);
      case RestaurantCardVariant.horizontal:
        return _HorizontalCard(card: this);
    }
  }
}

class _WideCard extends StatelessWidget {
  final RestaurantCard card;
  const _WideCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    final cover = RestaurantCover(
      imageUrl: card.coverUrl,
      fallbackText: card.name,
      borderRadius: BorderRadius.zero,
    );
    final textSection = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.sm,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.name,
            style: textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              card.subtitle!,
              style: textTheme.bodyMedium?.copyWith(color: muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              if (card.openStatus != null)
                StatusPill(
                  status: card.openStatus!,
                  label: card.openStatusLabel ?? '',
                ),
              if (card.distanceLabel != null) ...[
                if (card.openStatus != null)
                  const SizedBox(width: AppSpacing.s),
                _MetaDot(label: card.distanceLabel!),
              ],
              if (card.priceLabel != null) ...[
                const SizedBox(width: AppSpacing.s),
                _MetaDot(label: card.priceLabel!),
              ],
            ],
          ),
        ],
      ),
    );

    return _CardShell(
      onTap: card.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.hasBoundedHeight) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cover),
                textSection,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: cover),
              textSection,
            ],
          );
        },
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final RestaurantCard card;
  const _CompactCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    final cover = RestaurantCover(
      imageUrl: card.coverUrl,
      fallbackText: card.name,
      borderRadius: BorderRadius.zero,
    );
    final textSection = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.s,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.name,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              card.subtitle!,
              style: textTheme.bodySmall?.copyWith(color: muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (card.openStatus != null || card.distanceLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (card.openStatus != null)
                  Flexible(
                    child: StatusPill(
                      status: card.openStatus!,
                      label: card.openStatusLabel ?? '',
                    ),
                  ),
                if (card.distanceLabel != null) ...[
                  if (card.openStatus != null)
                    const SizedBox(width: AppSpacing.s),
                  Text(
                    card.distanceLabel!,
                    style: textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );

    return _CardShell(
      onTap: card.onTap,
      child: SizedBox(
        width: 220,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.hasBoundedHeight) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cover),
                  textSection,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(aspectRatio: 4 / 3, child: cover),
                textSection,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EditorialCard extends StatelessWidget {
  final RestaurantCard card;
  const _EditorialCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _CardShell(
      onTap: card.onTap,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RestaurantCover(
              imageUrl: card.coverUrl,
              fallbackText: card.name,
              borderRadius: BorderRadius.zero,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Color(0xCC1A1714), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.subtitle != null)
                    Text(
                      card.subtitle!.toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    card.name,
                    style: textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final RestaurantCard card;
  const _HorizontalCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    final cover = RestaurantCover(
      imageUrl: card.coverUrl,
      fallbackText: card.name,
      borderRadius: BorderRadius.zero,
    );
    final textSection = Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.name,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              card.subtitle!,
              style: textTheme.bodySmall?.copyWith(color: muted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (card.openStatus != null ||
              card.distanceLabel != null ||
              card.priceLabel != null) ...[
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (card.openStatus != null)
                  StatusPill(
                    status: card.openStatus!,
                    label: card.openStatusLabel ?? '',
                  ),
                if (card.distanceLabel != null)
                  _MetaDot(label: card.distanceLabel!),
                if (card.priceLabel != null)
                  _MetaDot(label: card.priceLabel!),
              ],
            ),
          ],
        ],
      ),
    );

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 130, child: cover),
        Expanded(child: textSection),
      ],
    );

    return _CardShell(
      onTap: card.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.hasBoundedHeight) {
            return body;
          }
          return SizedBox(height: 130, child: body);
        },
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _CardShell({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

class _MetaDot extends StatelessWidget {
  final String label;
  const _MetaDot({required this.label});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.inkMuted,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
      ],
    );
  }
}
