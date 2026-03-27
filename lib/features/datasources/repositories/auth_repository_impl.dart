import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/services/db_service.dart';
import 'package:menu_zen_restaurant/features/datasources/login_params.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/auth_repository.dart';
import 'package:menu_zen_restaurant/features/datasources/models/restaurant_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/role_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_model.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../../core/http_connexion/rest_client.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final RestClient rest;
  final DbService db;

  AuthRepositoryImpl({required this.db, required this.rest});

  @override
  Future<MultiResult<Failure, bool>> logout() async {
    final res = await db.deleteAll();
    if (res) {
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

  @override
  Future<MultiResult<Failure, UserRestaurantEntity>> updateUser(
    UserModel user,
  ) async {
    return executeWithErrorHandling(() async {
      final res = await rest.updateUser(user);
      final fullData = await rest.getUser();
      await db.saveUserRestaurant(fullData);
      return fullData;
    });
  }

  @override
  Future<MultiResult<Failure, RestaurantModel>> updateRestaurant(
    RestaurantModel restaurant,
  ) async {
    return executeWithErrorHandling(() async {
      final res = await rest.updateRestaurant(restaurant);
      // Refresh full data to keep consistency
      final fullData = await rest.getUser();
      await db.saveUserRestaurant(fullData);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, List<UserModel>>> getUsers() async {
    return executeWithErrorHandling(() async {
      return await rest.getUsers();
    });
  }

  @override
  Future<MultiResult<Failure, UserModel>> createUser(UserModel user) async {
    return executeWithErrorHandling(() async {
      return await rest.createUser(user);
    });
  }

  @override
  Future<MultiResult<Failure, UserModel>> updateAnyUser(UserModel user) async {
    return executeWithErrorHandling(() async {
      return await rest.updateAnyUser(user.id!, user);
    });
  }

  @override
  Future<MultiResult<Failure, bool>> deleteUser(int userId) async {
    return executeWithErrorHandling(() async {
      await rest.deleteUser(userId);
      return true;
    });
  }

  @override
  Future<MultiResult<Failure, List<RoleModel>>> getRoles() async {
    return executeWithErrorHandling(() async {
      return await rest.getRoles();
    });
  }

  @override
  Future<MultiResult<Failure, List<String>>> getPermissions() async {
    return executeWithErrorHandling(() async {
      return await rest.getPermissions();
    });
  }
}
