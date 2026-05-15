import 'package:equatable/equatable.dart';

import 'restaurant_public_entity.dart';

class RestaurantSearchResponseEntity extends Equatable {
  final int total;
  final List<RestaurantPublicEntity> items;

  const RestaurantSearchResponseEntity({
    required this.total,
    required this.items,
  });

  @override
  List<Object?> get props => [total, items];
}
