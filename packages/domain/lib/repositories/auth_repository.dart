import '../entities/role_entity.dart';
import '../entities/user_entity.dart';
import '../entities/restaurant_entity.dart';
import '../entities/user_restaurant_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/login_params.dart';

abstract class AuthRepository {
  Future<MultiResult<Failure, bool>> logout();
  Future<MultiResult<Failure, bool>> login(LoginParams user);
  Future<MultiResult<Failure, UserRestaurantEntity>> getUser();
  Future<MultiResult<Failure, UserRestaurantEntity>> updateUser(
    UserEntity user,
  );
  Future<MultiResult<Failure, RestaurantEntity>> updateRestaurant(
    RestaurantEntity restaurant,
  );
  Future<MultiResult<Failure, List<UserEntity>>> getUsers();
  Future<MultiResult<Failure, UserEntity>> createUser(UserEntity user);
  Future<MultiResult<Failure, UserEntity>> updateAnyUser(UserEntity user);
  Future<MultiResult<Failure, bool>> deleteUser(int userId);
  Future<MultiResult<Failure, List<RoleEntity>>> getRoles();
  Future<MultiResult<Failure, List<String>>> getPermissions();
}
