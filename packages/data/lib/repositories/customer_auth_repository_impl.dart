import 'package:domain/entities/customer_entity.dart';
import 'package:domain/entities/customer_token_entity.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/customer_login_params.dart';
import 'package:domain/params/customer_password_change_params.dart';
import 'package:domain/params/customer_register_params.dart';
import 'package:domain/params/customer_update_params.dart';
import 'package:domain/repositories/customer_auth_repository.dart';

import '../datasources/customers_remote_datasource.dart';
import '../errors/handle_exception.dart';
import '../services/customer_token_storage.dart';

class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final CustomersRemoteDatasource _remote;
  final CustomerTokenStorage _tokenStorage;

  CustomerAuthRepositoryImpl({
    required CustomersRemoteDatasource remote,
    required CustomerTokenStorage tokenStorage,
  }) : _remote = remote,
       _tokenStorage = tokenStorage;

  @override
  Future<MultiResult<Failure, CustomerTokenEntity>> register(
    CustomerRegisterParams params,
  ) {
    return executeWithErrorHandling(() async {
      final token = await _remote.register(params);
      await _tokenStorage.write(token.accessToken);
      return token;
    });
  }

  @override
  Future<MultiResult<Failure, CustomerTokenEntity>> login(
    CustomerLoginParams params,
  ) {
    return executeWithErrorHandling(() async {
      final token = await _remote.login(params);
      await _tokenStorage.write(token.accessToken);
      return token;
    });
  }

  @override
  Future<MultiResult<Failure, CustomerEntity>> me() {
    return executeWithErrorHandling(_remote.me);
  }

  @override
  Future<MultiResult<Failure, CustomerEntity>> updateMe(
    CustomerUpdateParams params,
  ) {
    return executeWithErrorHandling(() => _remote.updateMe(params));
  }

  @override
  Future<MultiResult<Failure, bool>> changePassword(
    CustomerPasswordChangeParams params,
  ) {
    return executeWithErrorHandling(() async {
      await _remote.changePassword(params);
      return true;
    });
  }

  @override
  Future<MultiResult<Failure, bool>> deleteMe() {
    return executeWithErrorHandling(() async {
      await _remote.deleteMe();
      await _tokenStorage.clear();
      return true;
    });
  }

  @override
  Future<MultiResult<Failure, bool>> logout() async {
    await _tokenStorage.clear();
    return SuccessResult(true);
  }
}
