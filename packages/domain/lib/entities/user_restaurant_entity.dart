import 'package:equatable/equatable.dart';
import 'restaurant_entity.dart';
import 'user_entity.dart';

class UserRestaurantEntity extends Equatable {
  final UserEntity user;
  final RestaurantEntity restaurant;

  const UserRestaurantEntity({required this.user, required this.restaurant});

  @override
  List<Object?> get props => [user, restaurant];
}
