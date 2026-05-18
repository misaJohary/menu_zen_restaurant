import 'package:design_system/design_system.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

class SearchResultCard extends StatelessWidget {
  final RestaurantPublicEntity restaurant;
  final VoidCallback? onTap;
  final RestaurantCardVariant variant;
  const SearchResultCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.variant = RestaurantCardVariant.wide,
  });

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final subtitleParts = <String>[];
    final type = restaurantTypeLabel(context, r.type?.name);
    if (type.isNotEmpty) subtitleParts.add(type);
    if (r.city.isNotEmpty) subtitleParts.add(r.city);
    final distance = formatDistanceKm(context, r.distanceKm);

    return RestaurantCard(
      name: r.name,
      subtitle: subtitleParts.join(' · '),
      coverUrl: r.cover ?? r.logo,
      distanceLabel: distance,
      onTap: onTap,
      variant: variant,
    );
  }
}
