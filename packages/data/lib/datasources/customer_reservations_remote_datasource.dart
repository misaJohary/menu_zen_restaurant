import 'package:dio/dio.dart';
import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:domain/params/customer_reservation_create_params.dart';

import '../models/customer_reservation_model.dart';

/// Talks to `/customers/me/reservations/*`. Expects a customer-scoped Dio
/// that already attaches the `Authorization: Bearer ...` header.
class CustomerReservationsRemoteDatasource {
  final Dio _dio;

  CustomerReservationsRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> createRaw(
    CustomerReservationCreateParams params,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/me/reservations',
      data: params.toJson(),
    );
    return response.data ?? const {};
  }

  Future<CustomerReservationEntity> create(
    CustomerReservationCreateParams params,
  ) async {
    return CustomerReservationModel.fromJson(await createRaw(params));
  }

  Future<List<Map<String, dynamic>>> listMineRaw({
    ReservationRequestStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/customers/me/reservations',
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

  Future<List<CustomerReservationEntity>> listMine({
    ReservationRequestStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final raw = await listMineRaw(
      status: status,
      limit: limit,
      offset: offset,
    );
    return raw.map(CustomerReservationModel.fromJson).toList();
  }

  Future<Map<String, dynamic>> getRaw(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers/me/reservations/$id',
    );
    return response.data ?? const {};
  }

  Future<CustomerReservationEntity> get(int id) async {
    return CustomerReservationModel.fromJson(await getRaw(id));
  }

  Future<Map<String, dynamic>> cancelRaw(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/customers/me/reservations/$id/cancel',
    );
    return response.data ?? const {};
  }

  Future<CustomerReservationEntity> cancel(int id) async {
    return CustomerReservationModel.fromJson(await cancelRaw(id));
  }
}
