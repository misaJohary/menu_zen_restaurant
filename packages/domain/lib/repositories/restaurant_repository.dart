import '../entities/user_restaurant_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class RestaurantRepository {
  Future<MultiResult<Failure, UserRestaurantEntity>> createRestaurant(
    UserRestaurantEntity userRestaurant,
  );
}
