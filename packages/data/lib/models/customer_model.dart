import 'package:domain/entities/customer_entity.dart';

import '../config/base_url_config.dart';

class CustomerModel {
  static CustomerEntity fromJson(Map<String, dynamic> json) {
    return CustomerEntity(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      avatar: _absoluteUrl(json['avatar'] as String?),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  static String? _absoluteUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${BaseUrlConfig.current}/$raw';
  }
}
