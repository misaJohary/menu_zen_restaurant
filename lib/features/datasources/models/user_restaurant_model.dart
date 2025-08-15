import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/datasources/models/restaurant_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/token.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';

part 'user_restaurant_model.g.dart';

@JsonSerializable()
class UserRestaurantModel extends UserRestaurantEntity {
  final Token? token;
  final UserModel _user;
  final RestaurantModel _restaurant;

  @override
  UserModel get user => _user;

  @override
  RestaurantModel get restaurant => _restaurant;

  const UserRestaurantModel({
    required UserModel user,
    required RestaurantModel restaurant,
    this.token,
  }) : _user = user,
        _restaurant = restaurant,
        super(user: user, restaurant: restaurant);

  /// Constructor from UserRestaurantEntity
  UserRestaurantModel.fromEntity(UserRestaurantEntity entity)
      : _user = UserModel.fromEntity(entity.user),
        _restaurant = RestaurantModel.fromEntity(entity.restaurant),
        token = null,
        super(user: entity.user, restaurant: entity.restaurant);

  factory UserRestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$UserRestaurantModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRestaurantModelToJson(this);
}