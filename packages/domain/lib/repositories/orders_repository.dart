import '../entities/order_entity.dart';
import '../entities/order_menu_item.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/order_params.dart';

abstract class OrdersRepository {
  Future<MultiResult<Failure, List<OrderMenuItem>>> getOrderMenuItems({
    String? search,
  });
  Future<MultiResult<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<MultiResult<Failure, List<OrderEntity>>> getOrders(OrderParams params);
  Future<MultiResult<Failure, OrderEntity>> updateStatusOrder(
    int orderId,
    OrderStatus orderStatus,
  );
  Future<MultiResult<Failure, OrderMenuItem>> updateOrderMenuItemStatus(
    int itemId,
    String status,
  );
  Future<MultiResult<Failure, dynamic>> deleteOrder(int orderId);
  Future<MultiResult<Failure, OrderEntity>> updateOrder(
    int orderId,
    OrderEntity order,
  );
}
