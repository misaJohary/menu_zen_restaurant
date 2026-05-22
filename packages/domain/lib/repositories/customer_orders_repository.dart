import '../entities/customer_order_entity.dart';
import '../entities/customer_order_status.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/customer_order_create_params.dart';

abstract class CustomerOrdersRepository {
  Future<MultiResult<Failure, CustomerOrderEntity>> create(
    CustomerOrderCreateParams params,
  );

  Future<MultiResult<Failure, List<CustomerOrderEntity>>> listMine({
    CustomerOrderStatus? status,
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, CustomerOrderEntity>> get(int id);

  Future<MultiResult<Failure, CustomerOrderEntity>> cancel(int id);
}
