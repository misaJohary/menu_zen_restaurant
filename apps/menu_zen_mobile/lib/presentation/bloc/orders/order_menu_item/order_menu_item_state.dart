part of 'order_menu_item_bloc.dart';

class OrderMenuItemState extends Equatable {
  const OrderMenuItemState({
    this.orderMenuItems = const [],
    this.orderedItems = const [],
    this.status = BlocStatus.init,
    this.customAddStatus = BlocStatus.init,
    this.selectedTableId,
  });

  final List<OrderMenuItem> orderMenuItems;
  final List<OrderMenuItem> orderedItems;
  final BlocStatus status;
  final BlocStatus customAddStatus;
  final int? selectedTableId;

  OrderMenuItemState copyWith({
    List<OrderMenuItem>? orderMenuItems,
    List<OrderMenuItem>? orderedItems,
    BlocStatus? status,
    BlocStatus? customAddStatus,
    int? selectedTableId,
    bool clearSelectedTableId = false,
  }) {
    return OrderMenuItemState(
      orderMenuItems: orderMenuItems ?? this.orderMenuItems,
      orderedItems: orderedItems ?? this.orderedItems,
      status: status ?? this.status,
      customAddStatus: customAddStatus ?? this.customAddStatus,
      selectedTableId: clearSelectedTableId
          ? null
          : (selectedTableId ?? this.selectedTableId),
    );
  }

  @override
  List<Object?> get props => [
    orderMenuItems,
    orderedItems,
    status,
    customAddStatus,
    selectedTableId,
  ];
}
