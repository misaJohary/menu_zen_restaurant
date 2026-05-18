import '../entities/customer_entity.dart';
import '../entities/customer_token_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/customer_login_params.dart';
import '../params/customer_password_change_params.dart';
import '../params/customer_register_params.dart';
import '../params/customer_update_params.dart';

abstract class CustomerAuthRepository {
  Future<MultiResult<Failure, CustomerTokenEntity>> register(
    CustomerRegisterParams params,
  );

  Future<MultiResult<Failure, CustomerTokenEntity>> login(
    CustomerLoginParams params,
  );

  Future<MultiResult<Failure, CustomerEntity>> me();

  Future<MultiResult<Failure, CustomerEntity>> updateMe(
    CustomerUpdateParams params,
  );

  Future<MultiResult<Failure, bool>> changePassword(
    CustomerPasswordChangeParams params,
  );

  Future<MultiResult<Failure, bool>> deleteMe();

  Future<MultiResult<Failure, bool>> logout();
}
