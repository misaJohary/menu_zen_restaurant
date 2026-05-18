import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';

import '../config/base_url_config.dart';
import 'opening_hours_model.dart';

class RestaurantDetailPublicModel {
  static RestaurantDetailPublicEntity fromJson(Map<String, dynamic> json) {
    return RestaurantDetailPublicEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: _parseType(json['type'] as String?),
      languages:
          (json['languages'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      logo: _absoluteUrl(json['logo'] as String?),
      cover: _absoluteUrl(json['cover'] as String?),
      pictures:
          (json['pictures'] as List?)
              ?.map((e) => _absoluteUrl(e.toString())!)
              .toList() ??
          const [],
      socialMedia:
          (json['social_media'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      openingHours: OpeningHoursModel.parse(
        json['opening_hours'] as Map<String, dynamic>?,
      ),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      disabled: json['disabled'] as bool? ?? false,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isOpenNow: json['is_open_now'] as bool? ?? false,
      nextOpening: _parseNextOpening(
        json['next_opening'] as Map<String, dynamic>?,
      ),
    );
  }

  static NextOpeningEntity? _parseNextOpening(Map<String, dynamic>? json) {
    if (json == null) return null;
    final day = json['day']?.toString();
    final time = json['time']?.toString();
    if (day == null || time == null) return null;
    return NextOpeningEntity(day: day, time: time);
  }

  static RestaurantType? _parseType(String? raw) {
    switch (raw) {
      case 'fastfood':
        return RestaurantType.fastfood;
      case 'casual':
        return RestaurantType.casual;
      case 'fine_dining':
        return RestaurantType.fineDining;
      default:
        return null;
    }
  }

  static String? _absoluteUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${BaseUrlConfig.current}/$raw';
  }
}
