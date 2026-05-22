import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/customer_reservation_create_params.dart';
import 'package:domain/repositories/customer_reservations_repository.dart';
import 'package:domain/services/connectivity_service.dart';

import '../datasources/customer_reservations_remote_datasource.dart';
import '../errors/handle_exception.dart';
import '../local/datasources/customer_reservations_local_datasource.dart';
import '../models/customer_reservation_model.dart';

class CustomerReservationsRepositoryImpl
    implements CustomerReservationsRepository {
  final CustomerReservationsRemoteDatasource _remote;
  final CustomerReservationsLocalDatasource _local;
  final ConnectivityService _connectivity;

  CustomerReservationsRepositoryImpl(
    this._remote,
    this._local,
    this._connectivity,
  );

  @override
  Future<MultiResult<Failure, CustomerReservationEntity>> create(
    CustomerReservationCreateParams params,
  ) async {
    if (!await _connectivity.isOnline()) {
      return FailureResult(InternetConnectionFailure());
    }
    final result = await executeWithErrorHandling(
      () => _remote.createRaw(params),
    );
    if (result.isSuccess) {
      final raw = result.getSuccess!;
      await _local.upsertReservation(raw);
      return SuccessResult(CustomerReservationModel.fromJson(raw));
    }
    return FailureResult(result.getError!);
  }

  @override
  Future<MultiResult<Failure, List<CustomerReservationEntity>>> listMine({
    ReservationRequestStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.listMineRaw(
          status: status,
          limit: limit,
          offset: offset,
        ),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        if (status == null && offset == 0) {
          await _local.replaceReservations(raw);
        }
        return SuccessResult(
          raw.map(CustomerReservationModel.fromJson).toList(),
        );
      }
    }
    final cached = await _local.getReservations();
    if (cached.isEmpty) {
      return FailureResult(InternetConnectionFailure());
    }
    var items = cached.map(CustomerReservationModel.fromJson).toList();
    if (status != null) {
      items = items.where((r) => r.status == status).toList();
    }
    return SuccessResult(items);
  }

  @override
  Future<MultiResult<Failure, CustomerReservationEntity>> get(int id) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.getRaw(id),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        await _local.upsertReservation(raw);
        return SuccessResult(CustomerReservationModel.fromJson(raw));
      }
    }
    final cached = await _local.getReservation(id);
    if (cached != null) {
      return SuccessResult(CustomerReservationModel.fromJson(cached));
    }
    return FailureResult(InternetConnectionFailure());
  }

  @override
  Future<MultiResult<Failure, CustomerReservationEntity>> cancel(int id) async {
    if (!await _connectivity.isOnline()) {
      return FailureResult(InternetConnectionFailure());
    }
    final result = await executeWithErrorHandling(
      () => _remote.cancelRaw(id),
    );
    if (result.isSuccess) {
      final raw = result.getSuccess!;
      await _local.upsertReservation(raw);
      return SuccessResult(CustomerReservationModel.fromJson(raw));
    }
    return FailureResult(result.getError!);
  }
}
