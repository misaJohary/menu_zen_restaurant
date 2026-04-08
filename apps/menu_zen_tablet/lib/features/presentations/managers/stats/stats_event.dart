part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();
}

class StatsRevenueGot extends StatsEvent {
  @override
  List<Object?> get props => [];
}

class StatsTopMenuItemsGot extends StatsEvent {
  @override
  List<Object?> get props => [];
}

class StatsTodayOrderCountGot extends StatsEvent {
  @override
  List<Object?> get props => [];
}
