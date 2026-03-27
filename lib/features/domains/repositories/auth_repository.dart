import 'package:menu_zen_restaurant/features/datasources/login_params.dart';
import 'package:menu_zen_restaurant/features/datasources/models/restaurant_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/role_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_model.dart';

import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../entities/user_restaurant_entity.dart';

abstract class AuthRepository {
  Future<MultiResult<Failure, bool>> logout();
  Future<MultiResult<Failure, bool>> login(LoginParams user);
  Future<MultiResult<Failure, UserRestaurantEntity>> getUser();
  Future<MultiResult<Failure, UserRestaurantEntity>> updateUser(UserModel user);
  Future<MultiResult<Failure, RestaurantModel>> updateRestaurant(
    RestaurantModel restaurant,
  );
  Future<MultiResult<Failure, List<UserModel>>> getUsers();
  Future<MultiResult<Failure, UserModel>> createUser(UserModel user);
  Future<MultiResult<Failure, UserModel>> updateAnyUser(UserModel user);
  Future<MultiResult<Failure, bool>> deleteUser(int userId);
  Future<MultiResult<Failure, List<RoleModel>>> getRoles();
  Future<MultiResult<Failure, List<String>>> getPermissions();
}
