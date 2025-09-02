part of 'orders_bloc.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.createStatus = BlocStatus.init,
    this.updateStatus = BlocStatus.init,
    this.selectedOrder,
    this.orders = const [],
    this.status = BlocStatus.init,
    this.deleteStatus = BlocStatus.init,
  });

  final BlocStatus createStatus;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final BlocStatus status;
  final BlocStatus updateStatus;
  final BlocStatus deleteStatus;

  copyWith({
    BlocStatus? createStatus,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    BlocStatus? status,
    BlocStatus? updateStatus,
    BlocStatus? deleteStatus,
  }) {
    return OrdersState(
      createStatus: createStatus ?? this.createStatus,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      status: status ?? this.status,
      updateStatus: updateStatus ?? this.updateStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
    );
  }

  @override
  List<Object?> get props => [
    createStatus,
    orders,
    status,
    updateStatus,
    deleteStatus,
  ];
}
