part of 'order_detail_cubit.dart';

@immutable
sealed class OrderDetailState {
  const OrderDetailState();
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final CustomerOrderEntity order;
  final String? lastErrorMessage;

  const OrderDetailLoaded(this.order, {this.lastErrorMessage});
}

class OrderDetailCancelling extends OrderDetailState {
  final CustomerOrderEntity order;
  const OrderDetailCancelling(this.order);
}

class OrderDetailError extends OrderDetailState {
  final String message;
  const OrderDetailError(this.message);
}
