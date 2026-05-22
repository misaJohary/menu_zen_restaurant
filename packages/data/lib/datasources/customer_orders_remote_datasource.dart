import 'package:dio/dio.dart';
import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:domain/params/customer_order_create_params.dart';

import '../models/customer_order_model.dart';

/// Talks to `/customers/me/orders/*`. Expects a customer-scoped Dio that
/// already attaches the `Authorization: Bearer ...` header.
class CustomerOrdersRemoteDatasource {
  final Dio _dio;

  CustomerOrdersRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> createRaw(
    CustomerOrderCreateParams params,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/me/orders',
      data: params.toJson(),
    );
    return response.data ?? const {};
  }

  Future<CustomerOrderEntity> create(
    CustomerOrderCreateParams params,
  ) async {
    return CustomerOrderModel.fromJson(await createRaw(params));
  }

  Future<List<Map<String, dynamic>>> listMineRaw({
    CustomerOrderStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/customers/me/orders',
      queryParameters: {
        if (status != null) 'status': status.apiValue,
        'limit': limit,
        'offset': offset,
      },
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<List<CustomerOrderEntity>> listMine({
    CustomerOrderStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final raw = await listMineRaw(
      status: status,
      limit: limit,
      offset: offset,
    );
    return raw.map(CustomerOrderModel.fromJson).toList();
  }

  Future<Map<String, dynamic>> getRaw(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers/me/orders/$id',
    );
    return response.data ?? const {};
  }

  Future<CustomerOrderEntity> get(int id) async {
    return CustomerOrderModel.fromJson(await getRaw(id));
  }

  Future<Map<String, dynamic>> cancelRaw(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/customers/me/orders/$id/cancel',
    );
    return response.data ?? const {};
  }

  Future<CustomerOrderEntity> cancel(int id) async {
    return CustomerOrderModel.fromJson(await cancelRaw(id));
  }
}
