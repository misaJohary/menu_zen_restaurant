part of 'order_menu_item_bloc.dart';

class OrderMenuItemState extends Equatable {
  const OrderMenuItemState({
    this.orderMenuItems = const [],
    this.orderedItems = const [],
    this.status = BlocStatus.init,
  });
  final List<OrderMenuItem> orderMenuItems;
  final List<OrderMenuItem> orderedItems;
  final BlocStatus status;

  OrderMenuItemState copyWith({
    List<OrderMenuItem>? orderMenuItems,
    List<OrderMenuItem>? orderedItems,
    BlocStatus? status,
  }) {
    return OrderMenuItemState(
      orderMenuItems: orderMenuItems ?? this.orderMenuItems,
      orderedItems: orderedItems ?? this.orderedItems,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [orderMenuItems, orderedItems, status];
}
