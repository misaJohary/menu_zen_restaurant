import 'package:design_system/design_system.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

class EditorialPick extends StatelessWidget {
  final String title;
  final RestaurantPublicEntity restaurant;
  final VoidCallback? onTap;

  const EditorialPick({
    super.key,
    required this.title,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.s),
        RestaurantCard(
          name: restaurant.name,
          subtitle: _subtitle(context, restaurant),
          coverUrl: restaurant.cover ?? restaurant.logo,
          variant: RestaurantCardVariant.editorial,
          onTap: onTap,
        ),
      ],
    );
  }

  String _subtitle(BuildContext context, RestaurantPublicEntity r) {
    final type = restaurantTypeLabel(context, r.type?.name);
    if (type.isNotEmpty) return type;
    return r.city;
  }
}
