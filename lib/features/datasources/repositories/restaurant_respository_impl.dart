import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/restaurant_repository.dart';

import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../models/user_restaurant_model.dart';

@LazySingleton(as: RestaurantRepository)
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestClient rest;

  RestaurantRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, UserRestaurantEntity>> createRestaurant(
    UserRestaurantEntity userRestaurant,
  ) async {
    if (userRestaurant is UserRestaurantModel) {
      return executeWithErrorHandling(() async {
        final res = await rest.createRestaurant(userRestaurant);
        return res;
      });
    }
    return FailureResult(UnexpectedFailure());
  }
}
