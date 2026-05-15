import 'package:dio/dio.dart';
import 'package:domain/entities/restaurant_search_response.dart';
import 'package:domain/params/restaurant_search_params.dart';

import '../models/restaurant_public_model.dart';
import '../models/restaurant_search_response_model.dart';

class PublicRestaurantsRemoteDatasource {
  final Dio _dio;

  PublicRestaurantsRemoteDatasource(this._dio);

  Future<RestaurantSearchResponseEntity> searchNearby(
    RestaurantSearchParams params,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/public/restaurants/search',
      queryParameters: {
        'lat': params.lat,
        'long': params.long,
        if (params.radiusKm != null) 'radius_km': params.radiusKm,
        if (params.q != null && params.q!.isNotEmpty) 'q': params.q,
        if (params.type != null) 'type': params.type!.apiValue,
        'limit': params.limit,
        'offset': params.offset,
      },
    );
    return RestaurantSearchResponseModel.fromJson(response.data ?? const {});
  }
}
