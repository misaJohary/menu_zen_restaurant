import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/customer_order_create_params.dart';
import 'package:domain/repositories/customer_orders_repository.dart';

import '../datasources/customer_orders_remote_datasource.dart';
import '../errors/handle_exception.dart';

class CustomerOrdersRepositoryImpl implements CustomerOrdersRepository {
  final CustomerOrdersRemoteDatasource _remote;

  CustomerOrdersRepositoryImpl(this._remote);

  @override
  Future<MultiResult<Failure, CustomerOrderEntity>> create(
    CustomerOrderCreateParams params,
  ) {
    return executeWithErrorHandling(() => _remote.create(params));
  }

  @override
  Future<MultiResult<Failure, List<CustomerOrderEntity>>> listMine({
    CustomerOrderStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listMine(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<MultiResult<Failure, CustomerOrderEntity>> get(int id) {
    return executeWithErrorHandling(() => _remote.get(id));
  }

  @override
  Future<MultiResult<Failure, CustomerOrderEntity>> cancel(int id) {
    return executeWithErrorHandling(() => _remote.cancel(id));
  }
}
