import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/features/domains/entities/restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_entity.dart';

abstract class UserRestaurantEntity extends Equatable {
  final UserEntity user;
  final RestaurantEntity restaurant;

  const UserRestaurantEntity({required this.user, required this.restaurant});

  @override
  List<Object?> get props => [user, restaurant];
}