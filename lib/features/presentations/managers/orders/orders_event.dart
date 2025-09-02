part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
}

class OrderCreated extends OrdersEvent {
  final OrderEntity orderEntity;

  const OrderCreated(this.orderEntity);

  @override
  List<Object?> get props => [orderEntity];
}

class OrderFetched extends OrdersEvent {
  const OrderFetched();

  @override
  List<Object?> get props => [];
}

class OrderStatusUpdated extends OrdersEvent {
  final int orderId;
  final OrderStatus orderStatus;

  const OrderStatusUpdated(this.orderId, this.orderStatus);

  @override
  List<Object?> get props => [orderId, orderStatus];
}

class OrderDeleted extends OrdersEvent {
  final int orderId;

  const OrderDeleted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderUpdated extends OrdersEvent {
  final OrderEntity orderEntity;

  const OrderUpdated(this.orderEntity);

  @override
  List<Object?> get props => [orderEntity];
}