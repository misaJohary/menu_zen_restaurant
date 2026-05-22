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

  Future<CustomerOrderEntity> create(
    CustomerOrderCreateParams params,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/me/orders',
      data: params.toJson(),
    );
    return CustomerOrderModel.fromJson(response.data ?? const {});
  }

  Future<List<CustomerOrderEntity>> listMine({
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
        .map(CustomerOrderModel.fromJson)
        .toList();
  }

  Future<CustomerOrderEntity> get(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers/me/orders/$id',
    );
    return CustomerOrderModel.fromJson(response.data ?? const {});
  }

  Future<CustomerOrderEntity> cancel(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/customers/me/orders/$id/cancel',
    );
    return CustomerOrderModel.fromJson(response.data ?? const {});
  }
}
