import 'package:design_system/design_system.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/route_paths.dart';
import '../../../../core/utils/formatters.dart';

class DiscoverRail extends StatelessWidget {
  final String title;
  final List<RestaurantPublicEntity> items;
  final bool showDistance;

  const DiscoverRail({
    super.key,
    required this.title,
    required this.items,
    required this.showDistance,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(title, style: textTheme.displayMedium),
        ),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 248,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, index) {
              final r = items[index];
              print(r.openingHours?.periods);
              final openStatus = resolveOpenStatus(r.openingHours);
              return RestaurantCard(
                name: r.name,
                subtitle: _subtitle(r),
                coverUrl: r.cover ?? r.logo,
                distanceLabel:
                    showDistance ? formatDistanceKm(r.distanceKm) : null,
                openStatus: openStatus?.status,
                openStatusLabel: openStatus?.label,
                variant: RestaurantCardVariant.compact,
                onTap: () => context.push(RoutePaths.restaurantDetail(r.id)),
              );
            },
          ),
        ),
      ],
    );
  }

  String _subtitle(RestaurantPublicEntity r) {
    final parts = <String>[];
    final type = restaurantTypeLabel(r.type?.name);
    if (type.isNotEmpty) parts.add(type);
    if (r.city.isNotEmpty) parts.add(r.city);
    return parts.join(' · ');
  }
}
