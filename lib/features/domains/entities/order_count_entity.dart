import 'package:equatable/equatable.dart';

class DailyOrderCount extends Equatable {
  final DateTime date;
  final int count;

  const DailyOrderCount({
    required this.date,
    required this.count,
  });

  @override
  List<Object?> get props => [date, count];
}

class OrderCountEntity extends Equatable {
  final List<DailyOrderCount> dailyCounts;

  final int totalCount;
  final double meanCount;
  final int todayCount;

  const OrderCountEntity({
    this.dailyCounts = const [],

    required this.todayCount,
    required this.totalCount,
    required this.meanCount,
  });

  @override
  List<Object?> get props => [dailyCounts, todayCount, meanCount, totalCount];
}
