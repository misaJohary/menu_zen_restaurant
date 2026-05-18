import 'package:dio/dio.dart';
import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:domain/entities/restaurant_search_response.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:domain/entities/review_summary_entity.dart';
import 'package:domain/params/restaurant_search_params.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';

import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/menu_model.dart';
import '../models/restaurant_detail_public_model.dart';
import '../models/restaurant_public_model.dart';
import '../models/restaurant_search_response_model.dart';
import '../models/review_model.dart';
import '../models/review_summary_model.dart';

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

  Future<RestaurantDetailPublicEntity> getRestaurant(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/public/restaurants/$id',
    );
    return RestaurantDetailPublicModel.fromJson(response.data ?? const {});
  }

  Future<List<MenuEntity>> listMenus(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/public/restaurants/$restaurantId/menus',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MenuModel.fromJson)
        .toList();
  }

  Future<List<CategoryEntity>> listCategories(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/public/restaurants/$restaurantId/categories',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  Future<List<MenuItemEntity>> listMenuItems(
    int restaurantId, {
    int? menuId,
    int? categoryId,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/public/restaurants/$restaurantId/menu-items',
      queryParameters: {
        if (menuId != null) 'menu_id': menuId,
        if (categoryId != null) 'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        'limit': limit,
        'offset': offset,
      },
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MenuItemModel.fromJson)
        .toList();
  }

  Future<MenuItemEntity> getMenuItem(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/public/menu-items/$id',
    );
    return MenuItemModel.fromJson(response.data ?? const {});
  }

  Future<List<ReviewEntity>> listReviews(
    int restaurantId, {
    ReviewSort sort = ReviewSort.recent,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/public/restaurants/$restaurantId/reviews',
      queryParameters: {
        'sort': sort.name,
        'limit': limit,
        'offset': offset,
      },
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList();
  }

  Future<ReviewSummaryEntity> getReviewSummary(int restaurantId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/public/restaurants/$restaurantId/reviews/summary',
    );
    return ReviewSummaryModel.fromJson(response.data ?? const {});
  }
}
