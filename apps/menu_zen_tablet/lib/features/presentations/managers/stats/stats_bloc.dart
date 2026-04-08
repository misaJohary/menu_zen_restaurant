import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:domain/entities/order_count_entity.dart';
import 'package:domain/entities/revenues_entity.dart';

import 'package:domain/entities/list_top_menu_item.dart';
import 'package:domain/repositories/stats_repository.dart';

part 'stats_event.dart';

part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsRepository statsRepository;

  StatsBloc({required this.statsRepository}) : super(StatsState()) {
    on<StatsRevenueGot>(_onStatsRevenueGot);
    on<StatsTopMenuItemsGot>(_onStatsTopMenuItemsGot);
    on<StatsTodayOrderCountGot>(_onStatsTodayOrderCountGot);
  }

  _onStatsRevenueGot(StatsRevenueGot event, Emitter<StatsState> emit) async {
    emit(state.copyWith(revenueStatus: BlocStatus.loading));
    final res = await statsRepository.getRevenue();
    if (res.isSuccess) {
      emit(
        state.copyWith(
          revenueStatus: BlocStatus.loaded,
          revenues: res.getSuccess,
        ),
      );
    } else {
      emit(state.copyWith(revenueStatus: BlocStatus.failed));
    }
  }

  _onStatsTopMenuItemsGot(
    StatsTopMenuItemsGot event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(topMenuStatus: BlocStatus.loading));
    final res = await statsRepository.getTopMenuItems();
    if (res.isSuccess) {
      emit(
        state.copyWith(
          topMenuStatus: BlocStatus.loaded,
          topMenuItems: res.getSuccess,
        ),
      );
    } else {
      emit(state.copyWith(topMenuStatus: BlocStatus.failed));
    }
  }

  _onStatsTodayOrderCountGot(
    StatsTodayOrderCountGot event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(orderCountStatus: BlocStatus.loading));
    final res = await statsRepository.getTodayOrderCount();
    if (res.isSuccess) {
      emit(
        state.copyWith(
          ordersCount: res.getSuccess,
          orderCountStatus: BlocStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(orderCountStatus: BlocStatus.failed));
    }
  }
}
