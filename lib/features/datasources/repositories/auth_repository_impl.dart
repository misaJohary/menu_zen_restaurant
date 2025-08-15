import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/services/db_service.dart';
import 'package:menu_zen_restaurant/features/datasources/login_params.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/auth_repository.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../models/user_restaurant_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final RestClient rest;
  final DbService db;

  AuthRepositoryImpl({required this.db, required this.rest});

  @override
  Future<MultiResult<Failure, bool>> logout() async {
     final res = await db
        .deleteAll();
     if(res) {
       return SuccessResult(res);
     } else {
       return FailureResult(Failure(message: 'Logout failed'));
     }
  }
  //
  @override
  Future<MultiResult<Failure, bool>> login(LoginParams params) async {
    return executeWithErrorHandling(() async {
      final res = await rest.login(params.username, params.password);
      await db.saveToken(res);
      return true;
    });
  }

  @override
  Future<MultiResult<Failure, UserRestaurantEntity>> getUser() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getUser();
        await db.saveUserRestaurant(res);
        return res;
    });
  }
}
