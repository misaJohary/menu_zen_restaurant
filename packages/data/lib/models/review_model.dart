import 'package:domain/entities/review_entity.dart';

import '../config/base_url_config.dart';

class ReviewModel {
  static ReviewEntity fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? const {};
    return ReviewEntity(
      id: (json['id'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      customer: ReviewCustomerEntity(
        id: (customer['id'] as num?)?.toInt() ?? 0,
        displayName: customer['display_name']?.toString() ?? '',
        avatar: _absoluteUrl(customer['avatar'] as String?),
      ),
    );
  }

  static String? _absoluteUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${BaseUrlConfig.current}/$raw';
  }
}
