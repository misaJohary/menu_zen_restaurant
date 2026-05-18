import 'package:dio/dio.dart';
import 'package:domain/entities/customer_entity.dart';
import 'package:domain/entities/customer_token_entity.dart';
import 'package:domain/params/customer_login_params.dart';
import 'package:domain/params/customer_password_change_params.dart';
import 'package:domain/params/customer_register_params.dart';
import 'package:domain/params/customer_update_params.dart';

import '../models/customer_model.dart';
import '../models/customer_token_model.dart';

/// Talks to `/customers/*` endpoints. Expects a Dio that already attaches the
/// `Authorization: Bearer ...` header on `/customers/me/*` requests.
class CustomersRemoteDatasource {
  final Dio _dio;

  CustomersRemoteDatasource(this._dio);

  Future<CustomerTokenEntity> register(CustomerRegisterParams params) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/register',
      data: params.toJson(),
    );
    return CustomerTokenModel.fromJson(response.data ?? const {});
  }

  Future<CustomerTokenEntity> login(CustomerLoginParams params) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/login',
      data: {'username': params.username, 'password': params.password},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return CustomerTokenModel.fromJson(response.data ?? const {});
  }

  Future<CustomerEntity> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/customers/me');
    return CustomerModel.fromJson(response.data ?? const {});
  }

  Future<CustomerEntity> updateMe(CustomerUpdateParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/customers/me',
      data: params.toJson(),
    );
    return CustomerModel.fromJson(response.data ?? const {});
  }

  Future<void> changePassword(CustomerPasswordChangeParams params) async {
    await _dio.post<void>('/customers/me/password', data: params.toJson());
  }

  Future<void> deleteMe() async {
    await _dio.delete<void>('/customers/me');
  }
}
