import 'package:domain/entities/review_summary_entity.dart';

class ReviewSummaryModel {
  static ReviewSummaryEntity fromJson(Map<String, dynamic> json) {
    final raw = json['histogram'];
    final histogram = <int, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final bucket = int.tryParse(key.toString());
        final count = (value is num) ? value.toInt() : null;
        if (bucket != null && count != null) histogram[bucket] = count;
      });
    }
    return ReviewSummaryEntity(
      avg: (json['avg'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      histogram: histogram,
    );
  }
}
