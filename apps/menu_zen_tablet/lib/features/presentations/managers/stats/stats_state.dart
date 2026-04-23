part of 'stats_bloc.dart';

class StatsState extends Equatable {
  const StatsState({
    this.revenues,
    this.ordersCount,
    this.topMenuItems,
    this.revenueStatus = BlocStatus.init,
    this.orderCountStatus = BlocStatus.init,
    this.topMenuStatus = BlocStatus.init,
  });

  final RevenuesEntity? revenues;
  final ListTopMenuItem? topMenuItems;
  final OrderCountEntity? ordersCount;
  final BlocStatus revenueStatus;
  final BlocStatus orderCountStatus;
  final BlocStatus topMenuStatus;

  @override
  List<Object?> get props => [
    revenues,
    topMenuItems,
    ordersCount,
    revenueStatus,
    orderCountStatus,
    topMenuStatus,
  ];

  StatsState copyWith({
    RevenuesEntity? revenues,
    ListTopMenuItem? topMenuItems,
    OrderCountEntity? ordersCount,
    BlocStatus? revenueStatus,
    BlocStatus? orderCountStatus,
    BlocStatus? topMenuStatus,
  }) {
    return StatsState(
      revenues: revenues ?? this.revenues,
      topMenuItems: topMenuItems ?? this.topMenuItems,
      ordersCount: ordersCount ?? this.ordersCount,
      revenueStatus: revenueStatus ?? this.revenueStatus,
      orderCountStatus: orderCountStatus ?? this.orderCountStatus,
      topMenuStatus: topMenuStatus ?? this.topMenuStatus,
    );
  }
}
