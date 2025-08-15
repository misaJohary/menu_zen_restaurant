import 'package:menu_zen_restaurant/features/datasources/login_params.dart';

import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../entities/user_restaurant_entity.dart';

abstract class AuthRepository{
  Future<MultiResult<Failure, bool>> logout();
  Future<MultiResult<Failure, bool>> login(LoginParams user);
  Future<MultiResult<Failure, UserRestaurantEntity>> getUser();
}