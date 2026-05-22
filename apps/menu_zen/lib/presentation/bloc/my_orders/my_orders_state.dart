part of 'my_orders_cubit.dart';

@immutable
sealed class MyOrdersState {
  final CustomerOrderStatus? filter;
  const MyOrdersState({this.filter});
}

class MyOrdersInitial extends MyOrdersState {
  const MyOrdersInitial() : super(filter: null);
}

class MyOrdersLoading extends MyOrdersState {
  const MyOrdersLoading({super.filter});
}

class MyOrdersLoaded extends MyOrdersState {
  final List<CustomerOrderEntity> items;
  final bool hasMore;
  final bool isLoadingMore;
  final String? lastErrorMessage;

  const MyOrdersLoaded({
    super.filter,
    this.items = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.lastErrorMessage,
  });

  MyOrdersLoaded copyWith({
    CustomerOrderStatus? filter,
    List<CustomerOrderEntity>? items,
    bool? hasMore,
    bool? isLoadingMore,
    String? lastErrorMessage,
    bool clearError = false,
  }) {
    return MyOrdersLoaded(
      filter: filter ?? this.filter,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastErrorMessage: clearError
          ? null
          : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }
}

class MyOrdersError extends MyOrdersState {
  final String message;
  const MyOrdersError({super.filter, required this.message});
}
