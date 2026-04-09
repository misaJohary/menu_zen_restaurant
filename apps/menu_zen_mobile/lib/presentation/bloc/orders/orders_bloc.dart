import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data/models/order_model.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:domain/entities/order_menu_item.dart';
import 'package:domain/params/order_params.dart';
import 'package:domain/repositories/orders_repository.dart';

import '../../../core/enums/bloc_status.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repo;

  OrdersBloc({required this.repo}) : super(const OrdersState()) {
    on<OrderCreated>(_onOrderCreated);
    on<OrderAdded>(_onOrderAdded);
    on<OrderFetched>(_onOrderFetched);
    on<OrderUpdated>(_onOrderUpdated);
    on<OrderRemoteUpdated>(_onOrderRemoteUpdated);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
    on<OrderStatusRemoteUpdated>(_onOrderStatusRemoteUpdated);
    on<OrderMenuItemStatusUpdated>(_onOrderMenuItemStatusUpdated);
    on<OrderMenuItemStatusRemoteUpdated>(_onOrderMenuItemStatusRemoteUpdated);
    on<OrderDeleted>(_onOrderDeleted);
    on<OrderRemoteDeleted>(_onOrderRemoteDeleted);
  }

  void _onOrderRemoteDeleted(
    OrderRemoteDeleted event,
    Emitter<OrdersState> emit,
  ) {
    emit(state.copyWith(
      orders: List.of(state.orders)
        ..removeWhere((e) => e.id == event.orderId),
    ));
  }

  void _onOrderRemoteUpdated(
    OrderRemoteUpdated event,
    Emitter<OrdersState> emit,
  ) {
    final index = state.orders.indexWhere((e) => e.id == event.orderEntity.id);
    if (index != -1) {
      emit(state.copyWith(
        orders: List.of(state.orders)
          ..removeAt(index)
          ..insert(index, OrderModel.fromEntity(event.orderEntity)),
      ));
    } else {
      add(const OrderFetched());
    }
  }

  void _onOrderStatusRemoteUpdated(
    OrderStatusRemoteUpdated event,
    Emitter<OrdersState> emit,
  ) {
    final index = state.orders.indexWhere((e) => e.id == event.orderId);
    if (index != -1) {
      final updated = state.orders[index].copyWith(
        orderStatus: event.orderStatus,
      );
      emit(state.copyWith(
        orders: List.of(state.orders)
          ..removeAt(index)
          ..insert(index, updated),
      ));
    } else {
      add(const OrderFetched());
    }
  }

  void _onOrderAdded(OrderAdded event, Emitter<OrdersState> emit) {
    emit(state.copyWith(
      orders: List.of(state.orders)
        ..insert(0, OrderModel.fromEntity(event.orderEntity)),
    ));
  }

  Future<void> _onOrderUpdated(
    OrderUpdated event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(updateStatus: BlocStatus.loading));
    final res = await repo.updateOrder(
      event.orderEntity.id!,
      OrderModel.fromEntity(event.orderEntity),
    );
    if (res.isSuccess) {
      final index = state.orders.indexWhere((e) => e.id == event.orderEntity.id);
      emit(state.copyWith(
        updateStatus: BlocStatus.loaded,
        selectedOrder: res.getSuccess,
        orders: List.of(state.orders)
          ..removeAt(index)
          ..insert(index, res.getSuccess!),
      ));
    } else {
      emit(state.copyWith(updateStatus: BlocStatus.failed));
    }
  }

  Future<void> _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(updateStatus: BlocStatus.loading));
    final res = await repo.updateStatusOrder(event.orderId, event.orderStatus);
    if (res.isSuccess) {
      final index = state.orders.indexWhere((e) => e.id == event.orderId);
      emit(state.copyWith(
        updateStatus: BlocStatus.loaded,
        orders: List.of(state.orders)
          ..removeAt(index)
          ..insert(index, res.getSuccess!),
      ));
    } else {
      emit(state.copyWith(updateStatus: BlocStatus.failed));
    }
  }

  Future<void> _onOrderMenuItemStatusUpdated(
    OrderMenuItemStatusUpdated event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(updateStatus: BlocStatus.loading));
    final res = await repo.updateOrderMenuItemStatus(
      event.orderMenuItemId,
      event.status,
    );
    if (res.isSuccess) {
      final orderIndex = state.orders.indexWhere((e) => e.id == event.orderId);
      if (orderIndex == -1) {
        emit(state.copyWith(updateStatus: BlocStatus.loaded));
        return;
      }
      final order = state.orders[orderIndex];
      final items = List<OrderMenuItem>.from(order.orderMenuItems);
      final updatedItem = res.getSuccess;
      if (updatedItem != null) {
        var itemIndex = items.indexWhere((i) => i.id == event.orderMenuItemId);
        if (itemIndex == -1) {
          itemIndex = items.indexWhere(
            (i) =>
                i.menuItemId == updatedItem.menuItemId ||
                i.menuItem.id == updatedItem.menuItem.id,
          );
        }
        if (itemIndex != -1) {
          items[itemIndex] = updatedItem;
        } else {
          items.add(updatedItem);
        }
      }
      final updatedOrder = order.copyWith(orderMenuItems: items);
      emit(state.copyWith(
        updateStatus: BlocStatus.loaded,
        orders: List.of(state.orders)
          ..removeAt(orderIndex)
          ..insert(orderIndex, updatedOrder),
      ));
    } else {
      emit(state.copyWith(updateStatus: BlocStatus.failed));
    }
  }

  void _onOrderMenuItemStatusRemoteUpdated(
    OrderMenuItemStatusRemoteUpdated event,
    Emitter<OrdersState> emit,
  ) {
    final orderIndex = state.orders.indexWhere((e) => e.id == event.orderId);
    if (orderIndex == -1) {
      add(const OrderFetched());
      return;
    }
    final order = state.orders[orderIndex];
    final items = List<OrderMenuItem>.from(order.orderMenuItems);
    final itemIndex = items.indexWhere((i) => i.id == event.orderMenuItemId);
    if (itemIndex == -1) {
      add(const OrderFetched());
      return;
    }
    items[itemIndex] = items[itemIndex].copyWith(status: event.status);
    final updatedOrder = order.copyWith(orderMenuItems: items);
    emit(state.copyWith(
      orders: List.of(state.orders)
        ..removeAt(orderIndex)
        ..insert(orderIndex, updatedOrder),
    ));
  }

  Future<void> _onOrderCreated(
    OrderCreated event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(createStatus: BlocStatus.loading));
    final res = await repo.createOrder(OrderModel.fromEntity(event.orderEntity));
    if (res.isSuccess) {
      emit(state.copyWith(
        createStatus: BlocStatus.loaded,
        selectedOrder: res.getSuccess,
      ));
    } else {
      emit(state.copyWith(createStatus: BlocStatus.failed));
    }
  }

  Future<void> _onOrderFetched(
    OrderFetched event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await repo.getOrders(
      OrderParams(todayOnly: false, search: event.search),
    );
    if (result.isSuccess) {
      emit(state.copyWith(
        orders: result.getSuccess,
        status: BlocStatus.loaded,
      ));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  Future<void> _onOrderDeleted(
    OrderDeleted event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: BlocStatus.loading));
    final res = await repo.deleteOrder(event.orderId);
    if (res.isSuccess) {
      emit(state.copyWith(
        deleteStatus: BlocStatus.loaded,
        orders: List.of(state.orders)
          ..removeWhere((e) => e.id == event.orderId),
      ));
    } else {
      emit(state.copyWith(deleteStatus: BlocStatus.failed));
    }
  }
}
