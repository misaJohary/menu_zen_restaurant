import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:domain/repositories/customer_orders_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_orders_state.dart';

class MyOrdersCubit extends Cubit<MyOrdersState> {
  static const int _pageSize = 20;

  final CustomerOrdersRepository _repository;

  MyOrdersCubit(this._repository) : super(const MyOrdersInitial());

  Future<void> load({CustomerOrderStatus? status}) async {
    emit(MyOrdersLoading(filter: status));
    final result = await _repository.listMine(
      status: status,
      limit: _pageSize,
      offset: 0,
    );
    if (result.isSuccess) {
      final items = result.getSuccess ?? const <CustomerOrderEntity>[];
      emit(
        MyOrdersLoaded(
          filter: status,
          items: items,
          hasMore: items.length == _pageSize,
        ),
      );
    } else {
      emit(
        MyOrdersError(
          filter: status,
          message: result.getError?.message ?? 'Could not load your orders.',
        ),
      );
    }
  }

  Future<void> refresh() => load(status: state.filter);

  Future<void> changeFilter(CustomerOrderStatus? status) =>
      load(status: status);

  Future<void> loadMore() async {
    final current = state;
    if (current is! MyOrdersLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));

    final result = await _repository.listMine(
      status: current.filter,
      limit: _pageSize,
      offset: current.items.length,
    );

    if (result.isSuccess) {
      final next = result.getSuccess ?? const <CustomerOrderEntity>[];
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
              result.getError?.message ?? 'Could not load more orders.',
        ),
      );
    }
  }

  /// Applies a fresh entity in-place after a detail-page update (cancel).
  void replaceOne(CustomerOrderEntity updated) {
    final current = state;
    if (current is! MyOrdersLoaded) return;
    final next = current.items
        .map((o) => o.id == updated.id ? updated : o)
        .toList();
    emit(current.copyWith(items: next));
  }
}
