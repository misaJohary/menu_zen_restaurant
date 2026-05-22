import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/reservation_request_status.dart';
import 'package:domain/repositories/customer_reservations_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_reservations_state.dart';

class MyReservationsCubit extends Cubit<MyReservationsState> {
  static const int _pageSize = 20;

  final CustomerReservationsRepository _repository;

  MyReservationsCubit(this._repository) : super(const MyReservationsInitial());

  Future<void> load({ReservationRequestStatus? status}) async {
    emit(MyReservationsLoading(filter: status));
    final result = await _repository.listMine(
      status: status,
      limit: _pageSize,
      offset: 0,
    );
    if (result.isSuccess) {
      final items = result.getSuccess ?? const <CustomerReservationEntity>[];
      emit(
        MyReservationsLoaded(
          filter: status,
          items: items,
          hasMore: items.length == _pageSize,
        ),
      );
    } else {
      emit(
        MyReservationsError(
          filter: status,
          message:
              result.getError?.message ?? 'Could not load your reservations.',
        ),
      );
    }
  }

  Future<void> refresh() => load(status: state.filter);

  Future<void> changeFilter(ReservationRequestStatus? status) => load(
    status: status,
  );

  Future<void> loadMore() async {
    final current = state;
    if (current is! MyReservationsLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));

    final result = await _repository.listMine(
      status: current.filter,
      limit: _pageSize,
      offset: current.items.length,
    );

    if (result.isSuccess) {
      final next = result.getSuccess ?? const <CustomerReservationEntity>[];
      emit(
        current.copyWith(
          items: [...current.items, ...next],
          hasMore: next.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } else {
      emit(
        current.copyWith(
          isLoadingMore: false,
          lastErrorMessage:
              result.getError?.message ?? 'Could not load more reservations.',
        ),
      );
    }
  }

  /// Applies a fresh entity in-place after a detail-page update (cancel).
  void replaceOne(CustomerReservationEntity updated) {
    final current = state;
    if (current is! MyReservationsLoaded) return;
    final next = current.items
        .map((r) => r.id == updated.id ? updated : r)
        .toList();
    emit(current.copyWith(items: next));
  }
}
