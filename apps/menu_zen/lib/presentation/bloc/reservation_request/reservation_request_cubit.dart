import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/params/customer_reservation_create_params.dart';
import 'package:domain/repositories/customer_reservations_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reservation_request_state.dart';

class ReservationRequestCubit extends Cubit<ReservationRequestState> {
  final CustomerReservationsRepository _repository;

  ReservationRequestCubit(this._repository)
    : super(const ReservationRequestIdle());

  Future<void> submit({
    required int restaurantId,
    required DateTime reservedAt,
    required String phone,
    required int partySize,
    String? note,
  }) async {
    emit(const ReservationRequestSubmitting());
    final result = await _repository.create(
      CustomerReservationCreateParams(
        restaurantId: restaurantId,
        reservedAt: reservedAt,
        phone: phone,
        partySize: partySize,
        note: note,
      ),
    );
    if (result.isSuccess && result.getSuccess != null) {
      emit(ReservationRequestSubmitted(result.getSuccess!));
    } else {
      emit(
        ReservationRequestError(
          result.getError?.message ?? 'Could not send your request.',
        ),
      );
    }
  }

  void reset() => emit(const ReservationRequestIdle());
}
