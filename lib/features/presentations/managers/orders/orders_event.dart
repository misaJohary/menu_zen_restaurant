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
  final String? search;
  const OrderFetched({this.search});

  @override
  List<Object?> get props => [search];
}

class OrderStatusUpdated extends OrdersEvent {
  final int orderId;
  final OrderStatus orderStatus;

  const OrderStatusUpdated(this.orderId, this.orderStatus);

  @override
  List<Object?> get props => [orderId, orderStatus];
}

class OrderStatusRemoteUpdated extends OrdersEvent {
  final int orderId;
  final OrderStatus orderStatus;

  const OrderStatusRemoteUpdated(this.orderId, this.orderStatus);

  @override
  List<Object?> get props => [orderId, orderStatus];
}

class OrderMenuItemStatusUpdated extends OrdersEvent {
  final int orderId;
  final int orderMenuItemId;
  final String status;

  const OrderMenuItemStatusUpdated(
    this.orderId,
    this.orderMenuItemId,
    this.status,
  );

  @override
  List<Object?> get props => [orderId, orderMenuItemId, status];
}

class OrderMenuItemStatusRemoteUpdated extends OrdersEvent {
  final int orderId;
  final int orderMenuItemId;
  final String status;

  const OrderMenuItemStatusRemoteUpdated(
    this.orderId,
    this.orderMenuItemId,
    this.status,
  );

  @override
  List<Object?> get props => [orderId, orderMenuItemId, status];
}

class OrderDeleted extends OrdersEvent {
  final int orderId;

  const OrderDeleted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderRemoteDeleted extends OrdersEvent {
  final int orderId;

  const OrderRemoteDeleted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderUpdated extends OrdersEvent {
  final OrderEntity orderEntity;

  const OrderUpdated(this.orderEntity);

  @override
  List<Object?> get props => [orderEntity];
}

class OrderRemoteUpdated extends OrdersEvent {
  final OrderEntity orderEntity;

  const OrderRemoteUpdated(this.orderEntity);

  @override
  List<Object?> get props => [orderEntity];
}

class OrderAdded extends OrdersEvent {
  final OrderEntity orderEntity;

  const OrderAdded(this.orderEntity);

  @override
  List<Object?> get props => [orderEntity];
}
