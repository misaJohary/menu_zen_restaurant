part of 'reservation_request_cubit.dart';

@immutable
sealed class ReservationRequestState {
  const ReservationRequestState();
}

class ReservationRequestIdle extends ReservationRequestState {
  const ReservationRequestIdle();
}

class ReservationRequestSubmitting extends ReservationRequestState {
  const ReservationRequestSubmitting();
}

class ReservationRequestSubmitted extends ReservationRequestState {
  final CustomerReservationEntity reservation;
  const ReservationRequestSubmitted(this.reservation);
}

class ReservationRequestError extends ReservationRequestState {
  final String message;
  const ReservationRequestError(this.message);
}
