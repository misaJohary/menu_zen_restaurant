part of 'order_menu_item_bloc.dart';

class OrderMenuItemState extends Equatable {

  const OrderMenuItemState({
    this.orderMenuItems = const [],
    this.status = BlocStatus.init,
  });
  final List<OrderMenuItem> orderMenuItems;
  final BlocStatus status;

  copyWith({
    List<OrderMenuItem>? orderMenuItems,
    BlocStatus? status,
  }) {
    return OrderMenuItemState(
      orderMenuItems: orderMenuItems ?? this.orderMenuItems,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [orderMenuItems, status];
}
