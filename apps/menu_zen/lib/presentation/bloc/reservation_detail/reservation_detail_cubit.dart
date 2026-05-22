import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/repositories/customer_reservations_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reservation_detail_state.dart';

class ReservationDetailCubit extends Cubit<ReservationDetailState> {
  final CustomerReservationsRepository _repository;

  ReservationDetailCubit(this._repository)
    : super(const ReservationDetailInitial());

  Future<void> load(int id) async {
    emit(const ReservationDetailLoading());
    final result = await _repository.get(id);
    if (result.isSuccess && result.getSuccess != null) {
      emit(ReservationDetailLoaded(result.getSuccess!));
    } else {
      emit(
        ReservationDetailError(
          result.getError?.message ?? 'Could not load this reservation.',
        ),
      );
    }
  }

  /// Seeds the state from a known entity (avoids a round-trip when navigating
  /// straight from the create flow with the reservation already in hand).
  void seed(CustomerReservationEntity reservation) {
    emit(ReservationDetailLoaded(reservation));
  }

  Future<void> cancel() async {
    final current = state;
    if (current is! ReservationDetailLoaded) return;
    emit(ReservationDetailCancelling(current.reservation));
    final result = await _repository.cancel(current.reservation.id);
    if (result.isSuccess && result.getSuccess != null) {
      emit(ReservationDetailLoaded(result.getSuccess!));
    } else {
      emit(
        ReservationDetailLoaded(
          current.reservation,
          lastErrorMessage:
              result.getError?.message ?? 'Could not cancel this reservation.',
        ),
      );
    }
  }
}
