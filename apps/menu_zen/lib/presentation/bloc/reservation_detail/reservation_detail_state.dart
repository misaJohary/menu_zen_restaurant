part of 'reservation_detail_cubit.dart';

@immutable
sealed class ReservationDetailState {
  const ReservationDetailState();
}

class ReservationDetailInitial extends ReservationDetailState {
  const ReservationDetailInitial();
}

class ReservationDetailLoading extends ReservationDetailState {
  const ReservationDetailLoading();
}

class ReservationDetailLoaded extends ReservationDetailState {
  final CustomerReservationEntity reservation;
  final String? lastErrorMessage;

  const ReservationDetailLoaded(this.reservation, {this.lastErrorMessage});
}

class ReservationDetailCancelling extends ReservationDetailState {
  final CustomerReservationEntity reservation;
  const ReservationDetailCancelling(this.reservation);
}

class ReservationDetailError extends ReservationDetailState {
  final String message;
  const ReservationDetailError(this.message);
}
