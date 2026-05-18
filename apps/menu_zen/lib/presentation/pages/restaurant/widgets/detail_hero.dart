import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class DetailHero extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;

  const DetailHero({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      color: scheme.tertiary.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        fallbackText.isEmpty ? '·' : fallbackText.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w600,
          color: scheme.tertiary,
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl == null || imageUrl!.isEmpty)
          fallback
        else
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.canvas),
            errorWidget: (_, __, ___) => fallback,
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x661A1714),
                Colors.transparent,
                Color(0x991A1714),
              ],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
      ],
    );
  }
}
