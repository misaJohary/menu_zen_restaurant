import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../datasources/models/order_menu_item_model.dart';
import '../../datasources/models/order_model.dart';
import '../entities/order_entity.dart';
import '../params/order_params.dart';

abstract class OrdersRepository {
  Future<MultiResult<Failure, List<OrderMenuItemModel>>> getOrderMenuItems();
  Future<MultiResult<Failure, OrderModel>> createOrder(OrderModel order);
  Future<MultiResult<Failure, List<OrderModel>>> getOrders(OrderParams params);
  Future<MultiResult<Failure, OrderModel>> updateStatusOrder(
    int orderId,
    OrderStatus orderStatus,
  );
  Future<MultiResult<Failure, OrderMenuItemModel>> updateOrderMenuItemStatus(
    int itemId,
    String status,
  );
  Future<MultiResult<Failure, dynamic>> deleteOrder(int orderId);

  Future<MultiResult<Failure, OrderModel>> updateOrder(
    int orderId,
    OrderModel order,
  );
}
