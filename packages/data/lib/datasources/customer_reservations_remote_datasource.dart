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

  Future<CustomerReservationEntity> create(
    CustomerReservationCreateParams params,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/me/reservations',
      data: params.toJson(),
    );
    return CustomerReservationModel.fromJson(response.data ?? const {});
  }

  Future<List<CustomerReservationEntity>> listMine({
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
        .map(CustomerReservationModel.fromJson)
        .toList();
  }

  Future<CustomerReservationEntity> get(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers/me/reservations/$id',
    );
    return CustomerReservationModel.fromJson(response.data ?? const {});
  }

  Future<CustomerReservationEntity> cancel(int id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/customers/me/reservations/$id/cancel',
    );
    return CustomerReservationModel.fromJson(response.data ?? const {});
  }
}
