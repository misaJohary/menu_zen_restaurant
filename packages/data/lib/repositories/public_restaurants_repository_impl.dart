import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:domain/entities/restaurant_search_response.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:domain/entities/review_summary_entity.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/restaurant_search_params.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';

import '../datasources/public_restaurants_remote_datasource.dart';
import '../errors/handle_exception.dart';

class PublicRestaurantsRepositoryImpl implements PublicRestaurantsRepository {
  final PublicRestaurantsRemoteDatasource _remote;

  PublicRestaurantsRepositoryImpl(this._remote);

  @override
  Future<MultiResult<Failure, RestaurantSearchResponseEntity>> searchNearby(
    RestaurantSearchParams params,
  ) {
    return executeWithErrorHandling(() => _remote.searchNearby(params));
  }

  @override
  Future<MultiResult<Failure, RestaurantDetailPublicEntity>> getRestaurant(
    int id,
  ) {
    return executeWithErrorHandling(() => _remote.getRestaurant(id));
  }

  @override
  Future<MultiResult<Failure, List<MenuEntity>>> listMenus(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listMenus(restaurantId, limit: limit, offset: offset),
    );
  }

  @override
  Future<MultiResult<Failure, List<CategoryEntity>>> listCategories(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listCategories(restaurantId, limit: limit, offset: offset),
    );
  }

  @override
  Future<MultiResult<Failure, List<MenuItemEntity>>> listMenuItems(
    int restaurantId, {
    int? menuId,
    int? categoryId,
    String? search,
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listMenuItems(
        restaurantId,
        menuId: menuId,
        categoryId: categoryId,
        search: search,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<MultiResult<Failure, MenuItemEntity>> getMenuItem(int id) {
    return executeWithErrorHandling(() => _remote.getMenuItem(id));
  }

  @override
  Future<MultiResult<Failure, List<ReviewEntity>>> listReviews(
    int restaurantId, {
    ReviewSort sort = ReviewSort.recent,
    int limit = 20,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listReviews(
        restaurantId,
        sort: sort,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<MultiResult<Failure, ReviewSummaryEntity>> getReviewSummary(
    int restaurantId,
  ) {
    return executeWithErrorHandling(
      () => _remote.getReviewSummary(restaurantId),
    );
  }
}
