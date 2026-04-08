import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../../../../core/enums/bloc_status.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:domain/entities/order_menu_item.dart';
import 'package:domain/repositories/orders_repository.dart';

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

  List<OrderMenuItem> _updateOrderedItems(
    List<OrderMenuItem> currentOrderedItems,
    OrderMenuItem updatedItem,
  ) {
    final items = List<OrderMenuItem>.from(currentOrderedItems);
    final index = items.indexWhere(
      (i) => i.menuItem.id == updatedItem.menuItem.id,
    );

    if (updatedItem.quantity > 0) {
      if (index >= 0) {
        items[index] = updatedItem;
      } else {
        items.add(updatedItem);
      }
    } else {
      if (index >= 0) {
        items.removeAt(index);
      }
    }
    return items;
  }

  _onOrderMenuUpdateInitiated(
    OrderMenuUpdateInitiated event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    //if (state.orderMenuItems.isEmpty) {
    await _onOrderMenuItemFetched(const OrderMenuItemFetched(), emit);
    //}

    final List<OrderMenuItem> orders = List.from(state.orderMenuItems);
    Logger().e(orders);
    if (orders.isEmpty) return;

    List<OrderMenuItem> orderedItems = [];
    for (final orderItem in event.order.orderMenuItems) {
      final index = orders.indexWhere(
        (item) => item.menuItem.id == orderItem.menuItem.id,
      );
      if (index != -1) {
        orders[index] = orders[index].copyWith(quantity: orderItem.quantity);
        orderedItems.add(orders[index]);
      } else {
        orderedItems.add(orderItem);
      }
    }
    emit(state.copyWith(orderMenuItems: orders, orderedItems: orderedItems));
  }

  _onOrderMenuItemCleared(
    OrderMenuItemCleared event,
    Emitter<OrderMenuItemState> emit,
  ) {
    List<OrderMenuItem>? orderMenuItems = [];
    for (var e in state.orderMenuItems) {
      orderMenuItems.add(e.copyWith(quantity: 0));
    }
    emit(
      state.copyWith(orderMenuItems: orderMenuItems, orderedItems: const []),
    );
  }

  _onOrderMenuItemFetched(
    OrderMenuItemFetched event,
    Emitter<OrderMenuItemState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await repo.getOrderMenuItems(search: event.search);
    if (result.isSuccess) {
      final fetchedItems = result.getSuccess ?? [];
      final orderMenuItems = fetchedItems.map((item) {
        final idx = state.orderedItems.indexWhere(
          (o) => o.menuItem.id == item.menuItem.id,
        );
        if (idx >= 0) {
          return item.copyWith(quantity: state.orderedItems[idx].quantity);
        }
        return item;
      }).toList();

      emit(
        state.copyWith(
          orderMenuItems: orderMenuItems,
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
      final newItem = item.copyWith(quantity: item.quantity + 1);
      orderMenuItems[event.index] = newItem;

      final orderedItems = _updateOrderedItems(state.orderedItems, newItem);
      emit(
        state.copyWith(
          orderMenuItems: orderMenuItems,
          orderedItems: orderedItems,
        ),
      );
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
        final newItem = item.copyWith(quantity: item.quantity - 1);
        orderMenuItems[event.index] = newItem;

        final orderedItems = _updateOrderedItems(state.orderedItems, newItem);
        emit(
          state.copyWith(
            orderMenuItems: orderMenuItems,
            orderedItems: orderedItems,
          ),
        );
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
        final newItem = item.copyWith(quantity: 0);
        orderMenuItems[index] = newItem;

        final orderedItems = _updateOrderedItems(state.orderedItems, newItem);
        emit(
          state.copyWith(
            orderMenuItems: orderMenuItems,
            orderedItems: orderedItems,
          ),
        );
      }
    } else {
      final newItem = event.orderMenuItem.copyWith(quantity: 0);
      final orderedItems = _updateOrderedItems(state.orderedItems, newItem);
      emit(state.copyWith(orderedItems: orderedItems));
    }
  }
}
