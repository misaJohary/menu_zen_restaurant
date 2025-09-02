part of 'order_menu_item_bloc.dart';

abstract class OrderMenuItemEvent extends Equatable {
  const OrderMenuItemEvent();
}

class OrderMenuItemFetched extends OrderMenuItemEvent {
  const OrderMenuItemFetched();

  @override
  List<Object?> get props => [];
}

class OrderMenuItemIncremented extends OrderMenuItemEvent {
  final int index;

  const OrderMenuItemIncremented(this.index);

  @override
  List<Object?> get props => [index];
}

class OrderMenuItemDecremented extends OrderMenuItemEvent {
  final int index;

  const OrderMenuItemDecremented(this.index);

  @override
  List<Object?> get props => [index];
}

class OrderMenuItemRemoved extends OrderMenuItemEvent {
  final OrderMenuItem orderMenuItem;

  const OrderMenuItemRemoved(this.orderMenuItem);

  @override
  List<Object?> get props => [orderMenuItem];
}

class OrderMenuItemCleared extends OrderMenuItemEvent {
  const OrderMenuItemCleared();

  @override
  List<Object?> get props => [];
}

class OrderMenuUpdateInitiated extends OrderMenuItemEvent {
  const OrderMenuUpdateInitiated(this.order);

  final OrderEntity order;

  @override
  List<Object?> get props => [order];
}
