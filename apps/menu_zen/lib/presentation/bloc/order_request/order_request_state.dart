part of 'order_request_cubit.dart';

@immutable
sealed class OrderRequestState {
  const OrderRequestState();
}

class OrderRequestIdle extends OrderRequestState {
  const OrderRequestIdle();
}

class OrderRequestSubmitting extends OrderRequestState {
  const OrderRequestSubmitting();
}

class OrderRequestSubmitted extends OrderRequestState {
  final CustomerOrderEntity order;
  const OrderRequestSubmitted(this.order);
}

class OrderRequestError extends OrderRequestState {
  final String message;
  const OrderRequestError(this.message);
}
