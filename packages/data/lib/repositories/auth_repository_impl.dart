import 'package:injectable/injectable.dart';
import 'package:data/services/db_service.dart';
import 'package:domain/params/login_params.dart';
import 'package:domain/entities/role_entity.dart';
import 'package:domain/entities/user_entity.dart';
import 'package:domain/entities/restaurant_entity.dart';
import 'package:domain/entities/user_restaurant_entity.dart';
import 'package:domain/repositories/auth_repository.dart';
import 'package:data/models/restaurant_model.dart';
import 'package:data/models/role_model.dart';
import 'package:data/models/user_model.dart';

import 'package:domain/errors/failure.dart';
import 'package:data/errors/handle_exception.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/http/rest_client.dart';

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
    UserEntity user,
  ) async {
    return executeWithErrorHandling(() async {
      final model = UserModel.fromEntity(user);
      await rest.updateUser(model);
      final fullData = await rest.getUser();
      await db.saveUserRestaurant(fullData);
      return fullData;
    });
  }

  @override
  Future<MultiResult<Failure, RestaurantEntity>> updateRestaurant(
    RestaurantEntity restaurant,
  ) async {
    return executeWithErrorHandling(() async {
      final model = RestaurantModel.fromEntity(restaurant);
      final res = await rest.updateRestaurant(model);
      final fullData = await rest.getUser();
      await db.saveUserRestaurant(fullData);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, List<UserEntity>>> getUsers() async {
    return executeWithErrorHandling(() async {
      return await rest.getUsers();
    });
  }

  @override
  Future<MultiResult<Failure, UserEntity>> createUser(UserEntity user) async {
    return executeWithErrorHandling(() async {
      final model = UserModel.fromEntity(user);
      return await rest.createUser(model);
    });
  }

  @override
  Future<MultiResult<Failure, UserEntity>> updateAnyUser(
    UserEntity user,
  ) async {
    return executeWithErrorHandling(() async {
      final model = UserModel.fromEntity(user);
      return await rest.updateAnyUser(model.id!, model);
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
  Future<MultiResult<Failure, List<RoleEntity>>> getRoles() async {
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
