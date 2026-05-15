import 'package:domain/entities/restaurant_search_response.dart';

import 'restaurant_public_model.dart';

class RestaurantSearchResponseModel {
  static RestaurantSearchResponseEntity fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RestaurantPublicModel.fromJson)
        .toList();
    return RestaurantSearchResponseEntity(
      total: (json['total'] as num?)?.toInt() ?? items.length,
      items: items,
    );
  }
}
