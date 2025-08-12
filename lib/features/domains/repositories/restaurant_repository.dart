import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';

import '../../../core/errors/failure.dart';
import '../../datasources/models/user_restaurant_model.dart';
import '../entities/user_restaurant_entity.dart';

abstract class RestaurantRepository{
  Future<MultiResult<Failure, UserRestaurantEntity>> createRestaurant(UserRestaurantEntity userRestaurant);
}