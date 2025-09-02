import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../../../../core/enums/bloc_status.dart';
import '../../../../domains/entities/order_entity.dart';
import '../../../../domains/entities/order_menu_item.dart';
import '../../../../domains/repositories/orders_repository.dart';

part 'order_menu_item_event.dart';

part 'order_menu_item_state.dart';

class OrderMenuItemBloc extends Bloc<OrderMenuItemEvent, OrderMenuItemState> {
  final OrdersRepository repo;

  OrderMenuItemBloc({required this.repo}) : super(OrderMenuItemState()) {
    on<OrderMenuItemFetched>(_onOrderMenuItemFetched);
    on<OrderMenuItemIncremented>(_onOrderMenuItemIncremented);
    on<OrderMenuItemDecremented>(_onOrderMenuItemDecremented);
    on<OrderMenuItemRemoved>(_onOrderMenuItemRemoved);
    on<OrderMenuItemCleared>(_onOrderMenuItemCleared);
    on<OrderMenuUpdateInitiated>(_onOrderMenuUpdateInitiated);
  }

  _onOrderMenuUpdateInitiated(
    OrderMenuUpdateInitiated event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    //if (state.orderMenuItems.isEmpty) {
      await _onOrderMenuItemFetched(OrderMenuItemFetched(), emit);
    //}

    final List<OrderMenuItem> orders = List.from(state.orderMenuItems);
    Logger().e(orders);
    if (orders.isEmpty) return;
    for (final orderItem in event.order.orderMenuItems) {
      final index = orders.indexWhere(
        (item) => item.menuItem.id == orderItem.menuItem.id,
      );
      if (index != -1) {
        orders[index] = orders[index].copyWith(quantity: orderItem.quantity);
      }
    }
    emit(state.copyWith(orderMenuItems: orders));
  }

  _onOrderMenuItemCleared(
    OrderMenuItemCleared event,
    Emitter<OrderMenuItemState> emit,
  ) {
    List<OrderMenuItem>? orderMenuItems = [];
    for (var e in state.orderMenuItems) {
      orderMenuItems.add(e.copyWith(quantity: 0));
    }
    emit(state.copyWith(orderMenuItems: orderMenuItems));
  }

  _onOrderMenuItemFetched(
    OrderMenuItemFetched event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await repo.getOrderMenuItems();
    if (result.isSuccess) {
      emit(
        state.copyWith(
          orderMenuItems: result.getSuccess,
          status: BlocStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onOrderMenuItemIncremented(
    OrderMenuItemIncremented event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final orderMenuItems = List<OrderMenuItem>.from(state.orderMenuItems);
    if (event.index >= 0 && event.index < orderMenuItems.length) {
      final item = orderMenuItems[event.index];
      orderMenuItems[event.index] = item.copyWith(quantity: item.quantity + 1);
      emit(state.copyWith(orderMenuItems: orderMenuItems));
    }
  }

  _onOrderMenuItemDecremented(
    OrderMenuItemDecremented event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final orderMenuItems = List<OrderMenuItem>.from(state.orderMenuItems);
    if (event.index >= 0 && event.index < orderMenuItems.length) {
      final item = orderMenuItems[event.index];
      if (item.quantity > 0) {
        orderMenuItems[event.index] = item.copyWith(
          quantity: item.quantity - 1,
        );
        emit(state.copyWith(orderMenuItems: orderMenuItems));
      }
    }
  }

  _onOrderMenuItemRemoved(
    OrderMenuItemRemoved event,
    Emitter<OrderMenuItemState> emit,
  ) {
    final orderMenuItems = List<OrderMenuItem>.from(state.orderMenuItems);
    final index = orderMenuItems.indexWhere(
      (menuItem) => menuItem.menuItem.id == event.orderMenuItem.menuItem.id,
    );
    if (index >= 0 && index < orderMenuItems.length) {
      final item = orderMenuItems[index];
      if (item.quantity > 0) {
        orderMenuItems[index] = item.copyWith(quantity: 0);
        emit(state.copyWith(orderMenuItems: orderMenuItems));
      }
    }
  }
}
