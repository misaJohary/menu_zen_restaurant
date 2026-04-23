import 'package:injectable/injectable.dart';
import 'package:data/errors/handle_exception.dart';
import 'package:data/models/order_model.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:domain/entities/order_menu_item.dart';

import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/http/rest_client.dart';
import 'package:domain/params/order_params.dart';
import 'package:domain/repositories/orders_repository.dart';
import 'package:data/models/order_menu_item_model.dart';

@LazySingleton(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  final RestClient rest;

  OrdersRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, List<OrderMenuItem>>> getOrderMenuItems({
    String? search,
  }) async {
    return executeWithErrorHandling(() async {
      return await rest.getMenuItemsOrder(search: search);
    });
  }

  @override
  Future<MultiResult<Failure, OrderEntity>> createOrder(
    OrderEntity order,
  ) async {
    return executeWithErrorHandling(() async {
      final model = OrderModel.fromEntity(order);
      return await rest.createOrder(model);
    });
  }

  @override
  Future<MultiResult<Failure, List<OrderEntity>>> getOrders(
    OrderParams params,
  ) async {
    return executeWithErrorHandling(() async {
      return await rest.getOrders(params.toJson());
    });
  }

  @override
  Future<MultiResult<Failure, OrderEntity>> updateStatusOrder(
    int orderId,
    OrderStatus orderStatus,
  ) async {
    return executeWithErrorHandling(() async {
      return await rest.updateOrderStatus(orderId, orderStatus.toJson);
    });
  }

  @override
  Future<MultiResult<Failure, OrderMenuItem>> updateOrderMenuItemStatus(
    int itemId,
    String status,
  ) async {
    return executeWithErrorHandling(() async {
      return await rest.updateOrderMenuItemStatus(itemId, {'status': status});
    });
  }

  @override
  Future<MultiResult<Failure, dynamic>> deleteOrder(int orderId) async {
    return executeWithErrorHandling(() async {
      return await rest.deleteOrder(orderId);
    });
  }

  @override
  Future<MultiResult<Failure, OrderEntity>> updateOrder(
    int orderId,
    OrderEntity order,
  ) {
    return executeWithErrorHandling(() async {
      final model = OrderModel.fromEntity(order);
      return await rest.updateOrder(orderId, model);
    });
  }
}
