import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// Cover image with a typographic fallback when the network image fails
/// or the URL is absent. Per design §3.5, the fallback is the restaurant's
/// initial on a category-tinted ground — no stock photos.
class RestaurantCover extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const RestaurantCover({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.lg);
    final fallback = _fallback(context);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: fit,
                width: width,
                height: height,
                placeholder: (_, __) => Container(color: AppColors.canvas),
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = fallbackText.isEmpty
        ? '·'
        : fallbackText.characters.first.toUpperCase();
    return Container(
      width: width,
      height: height,
      color: scheme.tertiary.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: scheme.tertiary,
        ),
      ),
    );
  }
}
