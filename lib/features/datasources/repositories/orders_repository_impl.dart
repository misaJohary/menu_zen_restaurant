import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/handle_exception.dart';
import 'package:menu_zen_restaurant/features/datasources/models/order_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_entity.dart';

import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../../domains/repositories/orders_repository.dart';
import '../models/order_menu_item_model.dart';

@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  final RestClient rest;

  OrdersRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, List<OrderMenuItemModel>>>
  getOrderMenuItems() async {
    return executeWithErrorHandling(() async {
      return await rest.getMenuItemsOrder();
    });
  }

  @override
  Future<MultiResult<Failure, OrderModel>> createOrder(OrderModel order) async {
    return executeWithErrorHandling(() async {
      return await rest.createOrder(order);
    });
  }

  @override
  Future<MultiResult<Failure, List<OrderModel>>> getOrders() async {
    return executeWithErrorHandling(() async {
      return await rest.getOrders();
    });
  }

  @override
  Future<MultiResult<Failure, OrderModel>> updateStatusOrder(
    int orderId,
    OrderStatus orderStatus,
  ) async {
    return executeWithErrorHandling(() async {
      return await rest.updateOrderStatus(orderId, orderStatus.toJson);
    });
  }

  @override
  Future<MultiResult<Failure, dynamic>> deleteOrder(int orderId) async {
    return executeWithErrorHandling(() async {
      return await rest.deleteOrder(orderId);
    });
  }

  @override
  Future<MultiResult<Failure, OrderModel>> updateOrder(
    int orderId,
    OrderModel order,
  ) {
    return executeWithErrorHandling(() async {
      return await rest.updateOrder(orderId, order);
    });
  }
}
