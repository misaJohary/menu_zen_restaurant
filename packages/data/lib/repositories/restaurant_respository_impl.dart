import 'package:injectable/injectable.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/services/db_service.dart';
import 'package:domain/entities/user_restaurant_entity.dart';
import 'package:domain/repositories/restaurant_repository.dart';

import 'package:data/errors/handle_exception.dart';
import 'package:data/http/rest_client.dart';
import 'package:data/models/user_restaurant_model.dart';

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
      final res = await rest.createRestaurant(
        UserRestaurantModel.fromEntity(userRestaurant),
      );
      db.saveUserRestaurant(res);
      if (res.token != null) {
        db.saveToken(res.token!);
      }
      return res;
    });
  }
}
