import 'package:dio/dio.dart';
import 'package:domain/entities/favorite_entity.dart';

import '../models/favorite_model.dart';

/// Talks to `/customers/me/favorites/*`. Expects a customer-scoped Dio that
/// already attaches the `Authorization: Bearer ...` header.
class CustomerFavoritesRemoteDatasource {
  final Dio _dio;

  CustomerFavoritesRemoteDatasource(this._dio);

  Future<List<FavoriteEntity>> list({int limit = 50, int offset = 0}) async {
    final response = await _dio.get<List<dynamic>>(
      '/customers/me/favorites',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FavoriteModel.fromJson)
        .toList();
  }

  Future<FavoriteEntity> add(int restaurantId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/me/favorites',
      data: {'restaurant_id': restaurantId},
    );
    return FavoriteModel.fromJson(response.data ?? const {});
  }

  Future<void> remove(int restaurantId) async {
    await _dio.delete<void>('/customers/me/favorites/$restaurantId');
  }
}
