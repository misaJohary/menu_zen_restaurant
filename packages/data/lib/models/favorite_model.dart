import 'package:domain/entities/favorite_entity.dart';

import 'restaurant_public_model.dart';

class FavoriteModel {
  static FavoriteEntity fromJson(Map<String, dynamic> json) {
    return FavoriteEntity(
      id: (json['id'] as num).toInt(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      restaurant: RestaurantPublicModel.fromJson(
        json['restaurant'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
