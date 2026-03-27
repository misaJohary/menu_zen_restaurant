// class DailyRevenue(BaseModel):
// date: date
// revenue: float
//
// class RevenueSummary(BaseModel):
// revenue: float
//
// class RevenueListResponse(BaseModel):
// daily_revenues: List[DailyRevenue]
// total_revenue: float

import 'package:equatable/equatable.dart';

class DailyRevenue extends Equatable {
  final DateTime date;
  final double revenue;

  const DailyRevenue({required this.date, required this.revenue});

  @override
  List<Object?> get props => [date, revenue];
}

class RevenuesEntity extends Equatable {
  final List<DailyRevenue> dailyRevenues;
  final double totalRevenue;
  final double diffPercentage;
  final double todayRevenue;

  const RevenuesEntity({
    this.dailyRevenues = const [],
    required this.totalRevenue,
    required this.diffPercentage,
    required this.todayRevenue,
  });

  @override
  List<Object?> get props => [
    dailyRevenues,
    totalRevenue,
    diffPercentage,
    todayRevenue,
  ];
}
