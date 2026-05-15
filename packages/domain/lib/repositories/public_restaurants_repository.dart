import '../entities/restaurant_search_response.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/restaurant_search_params.dart';

abstract class PublicRestaurantsRepository {
  Future<MultiResult<Failure, RestaurantSearchResponseEntity>> searchNearby(
    RestaurantSearchParams params,
  );
}
