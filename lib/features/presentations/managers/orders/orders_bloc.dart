import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../datasources/models/order_model.dart';
import '../../../domains/entities/order_entity.dart';
import '../../../domains/params/order_params.dart';
import '../../../domains/repositories/orders_repository.dart';

part 'orders_event.dart';

part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repo;

  OrdersBloc({required this.repo}) : super(OrdersState()) {
    on<OrderCreated>(_onOrderCreated);
    on<OrderAdded>(_onOrderAdded);
    on<OrderFetched>(_onOrderFetched);
    on<OrderUpdated>(_onOrderUpdated);
    on<OrderRemoteUpdated>(_onOrderRemoteUpdated);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
    on<OrderStatusRemoteUpdated>(_onOrderStatusRemoteUpdated);
    on<OrderDeleted>(_onOrderDeleted);
    on<OrderRemoteDeleted>(_onOrderRemoteDeleted);

  }

  _onOrderRemoteDeleted(
    OrderRemoteDeleted event,
    Emitter<OrdersState> emit,
  ) {
    emit(
      state.copyWith(
        orders: List.of(state.orders)
          ..removeWhere((element) => element.id == event.orderId),
      ),
    );
  }

  _onOrderRemoteUpdated(
    OrderRemoteUpdated event,
    Emitter<OrdersState> emit,
  ) {
    final index = state.orders.indexWhere(
      (element) => element.id == event.orderEntity.id,
    );
    if (index != -1) {
      emit(
        state.copyWith(
          orders: List.of(state.orders)
            ..removeAt(index)
            ..insert(
              index,
              OrderModel.fromEntity(event.orderEntity),
            ),
        ),
      );
    } else {
      add(OrderFetched());
    }
  }

  _onOrderStatusRemoteUpdated(
    OrderStatusRemoteUpdated event,
    Emitter<OrdersState> emit,
  ) {
    final index = state.orders.indexWhere(
      (element) => element.id == event.orderId,
    );
    if (index != -1) {
      final updatedOrder = state.orders[index].copyWith(
        orderStatus: event.orderStatus,
      );
      emit(
        state.copyWith(
          orders: List.of(state.orders)
            ..removeAt(index)
            ..insert(index, updatedOrder),
        ),
      );
    } else {
      add(OrderFetched());
    }
  }

  _onOrderAdded(OrderAdded event, Emitter<OrdersState> emit) {
    emit(
      state.copyWith(
        orders: List.of(state.orders)
          ..insert(0, OrderModel.fromEntity(event.orderEntity)),
      ),
    );
  }

  _onOrderUpdated(OrderUpdated event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(updateStatus: BlocStatus.loading));
    final res = await repo.updateOrder(
      event.orderEntity.id!,
      OrderModel.fromEntity(event.orderEntity),
    );
    if (res.isSuccess) {
      final index = state.orders.indexWhere(
        (element) => element.id == event.orderEntity.id,
      );
      emit(
        state.copyWith(
          updateStatus: BlocStatus.loaded,
          selectedOrder: res.getSuccess,
          orders: List.of(state.orders)
            ..removeAt(index)
            ..insert(index, res.getSuccess!),
        ),
      );
    } else {
      emit(state.copyWith(updateStatus: BlocStatus.failed));
    }
  }

  _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(updateStatus: BlocStatus.loading));
    final res = await repo.updateStatusOrder(event.orderId, event.orderStatus);
    if (res.isSuccess) {
      final index = state.orders.indexWhere(
        (element) => element.id == event.orderId,
      );
      emit(
        state.copyWith(
          updateStatus: BlocStatus.loaded,
          orders: List.of(state.orders)
            ..removeAt(index)
            ..insert(index, res.getSuccess!),
        ),
      );
    } else {
      Logger().i('is failure');
      emit(state.copyWith(updateStatus: BlocStatus.failed));
    }
  }

  _onOrderCreated(OrderCreated event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(createStatus: BlocStatus.loading));
    final res = await repo.createOrder(
      OrderModel.fromEntity(event.orderEntity),
    );
    if (res.isSuccess) {
      emit(
        state.copyWith(
          createStatus: BlocStatus.loaded,
          selectedOrder: res.getSuccess,
        ),
      );
    } else {
      emit(state.copyWith(createStatus: BlocStatus.failed));
    }
  }

  _onOrderFetched(OrderFetched event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final result = await repo.getOrders(OrderParams(todayOnly: true));
    if (result.isSuccess) {
      emit(
        state.copyWith(orders: result.getSuccess, status: BlocStatus.loaded),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onOrderDeleted(OrderDeleted event, Emitter<OrdersState> emit) async {
    emit(state.copyWith(deleteStatus: BlocStatus.loading));
    final res = await repo.deleteOrder(event.orderId);
    if (res.isSuccess) {
      emit(
        state.copyWith(
          deleteStatus: BlocStatus.loaded,
          orders: List.of(state.orders)
            ..removeWhere((element) => element.id == event.orderId),
        ),
      );
    } else {
      emit(state.copyWith(deleteStatus: BlocStatus.failed));
    }
  }
}
