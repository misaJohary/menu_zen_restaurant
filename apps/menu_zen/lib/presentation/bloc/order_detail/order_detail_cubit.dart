import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/repositories/customer_orders_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final CustomerOrdersRepository _repository;

  OrderDetailCubit(this._repository) : super(const OrderDetailInitial());

  Future<void> load(int id) async {
    emit(const OrderDetailLoading());
    final result = await _repository.get(id);
    if (result.isSuccess && result.getSuccess != null) {
      emit(OrderDetailLoaded(result.getSuccess!));
    } else {
      emit(
        OrderDetailError(
          result.getError?.message ?? 'Could not load this order.',
        ),
      );
    }
  }

  /// Seeds the state from a known entity (avoids a round-trip when navigating
  /// straight from the create flow with the order already in hand).
  void seed(CustomerOrderEntity order) {
    emit(OrderDetailLoaded(order));
  }

  Future<void> cancel() async {
    final current = state;
    if (current is! OrderDetailLoaded) return;
    emit(OrderDetailCancelling(current.order));
    final result = await _repository.cancel(current.order.id);
    if (result.isSuccess && result.getSuccess != null) {
      emit(OrderDetailLoaded(result.getSuccess!));
    } else {
      emit(
        OrderDetailLoaded(
          current.order,
          lastErrorMessage:
              result.getError?.message ?? 'Could not cancel this order.',
        ),
      );
    }
  }
}
