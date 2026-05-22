import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/customer_reservation_create_params.dart';
import 'package:domain/repositories/customer_reservations_repository.dart';

import '../datasources/customer_reservations_remote_datasource.dart';
import '../errors/handle_exception.dart';

class CustomerReservationsRepositoryImpl
    implements CustomerReservationsRepository {
  final CustomerReservationsRemoteDatasource _remote;

  CustomerReservationsRepositoryImpl(this._remote);

  @override
  Future<MultiResult<Failure, CustomerReservationEntity>> create(
    CustomerReservationCreateParams params,
  ) {
    return executeWithErrorHandling(() => _remote.create(params));
  }

  @override
  Future<MultiResult<Failure, List<CustomerReservationEntity>>> listMine({
    ReservationRequestStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listMine(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<MultiResult<Failure, CustomerReservationEntity>> get(int id) {
    return executeWithErrorHandling(() => _remote.get(id));
  }

  @override
  Future<MultiResult<Failure, CustomerReservationEntity>> cancel(int id) {
    return executeWithErrorHandling(() => _remote.cancel(id));
  }
}
