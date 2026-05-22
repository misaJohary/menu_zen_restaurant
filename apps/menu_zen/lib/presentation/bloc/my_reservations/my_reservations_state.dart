part of 'my_reservations_cubit.dart';

@immutable
sealed class MyReservationsState {
  final ReservationRequestStatus? filter;
  const MyReservationsState({this.filter});
}

class MyReservationsInitial extends MyReservationsState {
  const MyReservationsInitial() : super(filter: null);
}

class MyReservationsLoading extends MyReservationsState {
  const MyReservationsLoading({super.filter});
}

class MyReservationsLoaded extends MyReservationsState {
  final List<CustomerReservationEntity> items;
  final bool hasMore;
  final bool isLoadingMore;
  final String? lastErrorMessage;

  const MyReservationsLoaded({
    super.filter,
    this.items = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.lastErrorMessage,
  });

  MyReservationsLoaded copyWith({
    ReservationRequestStatus? filter,
    List<CustomerReservationEntity>? items,
    bool? hasMore,
    bool? isLoadingMore,
    String? lastErrorMessage,
    bool clearError = false,
  }) {
    return MyReservationsLoaded(
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

class MyReservationsError extends MyReservationsState {
  final String message;
  const MyReservationsError({super.filter, required this.message});
}
