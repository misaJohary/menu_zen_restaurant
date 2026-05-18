import 'package:equatable/equatable.dart';

class ReviewSummaryEntity extends Equatable {
  final double avg;
  final int count;

  /// 1..5 → count of reviews at that rating.
  final Map<int, int> histogram;

  const ReviewSummaryEntity({
    required this.avg,
    required this.count,
    this.histogram = const {},
  });

  @override
  List<Object?> get props => [avg, count, histogram];
}
