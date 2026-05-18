import 'package:equatable/equatable.dart';

import 'restaurant_public_entity.dart';

class FavoriteEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final RestaurantPublicEntity restaurant;

  const FavoriteEntity({
    required this.id,
    required this.createdAt,
    required this.restaurant,
  });

  @override
  List<Object?> get props => [id, createdAt, restaurant];
}
