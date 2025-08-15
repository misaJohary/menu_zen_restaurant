import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/core/services/db_service.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/restaurant_repository.dart';

import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../models/user_restaurant_model.dart';

@LazySingleton(as: RestaurantRepository)
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestClient rest;
  final DbService db;

  RestaurantRepositoryImpl({required this.rest, required this.db});

  @override
  Future<MultiResult<Failure, UserRestaurantEntity>> createRestaurant(
    UserRestaurantEntity userRestaurant,
  ) async {
      return executeWithErrorHandling(() async {
        final res = await rest.createRestaurant(UserRestaurantModel.fromEntity(userRestaurant));
        db.saveUserRestaurant(res);
        if(res.token != null) {
          db.saveToken(res.token!);
        }
        return res;
      });
  }
}