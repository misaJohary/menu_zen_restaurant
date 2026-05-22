import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/customer_order_create_params.dart';
import 'package:domain/repositories/customer_orders_repository.dart';
import 'package:domain/services/connectivity_service.dart';

import '../datasources/customer_orders_remote_datasource.dart';
import '../errors/handle_exception.dart';
import '../local/datasources/customer_orders_local_datasource.dart';
import '../models/customer_order_model.dart';

class CustomerOrdersRepositoryImpl implements CustomerOrdersRepository {
  final CustomerOrdersRemoteDatasource _remote;
  final CustomerOrdersLocalDatasource _local;
  final ConnectivityService _connectivity;

  CustomerOrdersRepositoryImpl(
    this._remote,
    this._local,
    this._connectivity,
  );

  @override
  Future<MultiResult<Failure, CustomerOrderEntity>> create(
    CustomerOrderCreateParams params,
  ) async {
    // Online-only write — guarded at the cubit layer too, but enforce here
    // to keep the contract honest.
    if (!await _connectivity.isOnline()) {
      return FailureResult(InternetConnectionFailure());
    }
    final result = await executeWithErrorHandling(
      () => _remote.createRaw(params),
    );
    if (result.isSuccess) {
      final raw = result.getSuccess!;
      await _local.upsertOrder(raw);
      return SuccessResult(CustomerOrderModel.fromJson(raw));
    }
    return FailureResult(result.getError!);
  }

  @override
  Future<MultiResult<Failure, List<CustomerOrderEntity>>> listMine({
    CustomerOrderStatus? status,
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
        // Only the first unfiltered page hydrates the offline cache —
        // status-filtered views don't represent the full history.
        if (status == null && offset == 0) {
          await _local.replaceOrders(raw);
        }
        return SuccessResult(
          raw.map(CustomerOrderModel.fromJson).toList(),
        );
      }
    }
    final cached = await _local.getOrders();
    if (cached.isEmpty) {
      return FailureResult(InternetConnectionFailure());
    }
    var items = cached.map(CustomerOrderModel.fromJson).toList();
    if (status != null) {
      items = items.where((o) => o.orderStatus == status).toList();
    }
    return SuccessResult(items);
  }

  @override
  Future<MultiResult<Failure, CustomerOrderEntity>> get(int id) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.getRaw(id),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        await _local.upsertOrder(raw);
        return SuccessResult(CustomerOrderModel.fromJson(raw));
      }
    }
    final cached = await _local.getOrder(id);
    if (cached != null) {
      return SuccessResult(CustomerOrderModel.fromJson(cached));
    }
    return FailureResult(InternetConnectionFailure());
  }

  @override
  Future<MultiResult<Failure, CustomerOrderEntity>> cancel(int id) async {
    if (!await _connectivity.isOnline()) {
      return FailureResult(InternetConnectionFailure());
    }
    final result = await executeWithErrorHandling(
      () => _remote.cancelRaw(id),
    );
    if (result.isSuccess) {
      final raw = result.getSuccess!;
      await _local.upsertOrder(raw);
      return SuccessResult(CustomerOrderModel.fromJson(raw));
    }
    return FailureResult(result.getError!);
  }
}
