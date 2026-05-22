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
import 'package:domain/services/connectivity_service.dart';

import '../datasources/public_restaurants_remote_datasource.dart';
import '../errors/handle_exception.dart';
import '../local/datasources/public_restaurants_local_datasource.dart';
import '../models/menu_item_model.dart';
import '../models/menu_model.dart';
import '../models/restaurant_detail_public_model.dart';
import '../models/restaurant_public_model.dart';
import '../models/review_model.dart';

class PublicRestaurantsRepositoryImpl implements PublicRestaurantsRepository {
  final PublicRestaurantsRemoteDatasource _remote;
  final PublicRestaurantsLocalDatasource _local;
  final ConnectivityService _connectivity;

  PublicRestaurantsRepositoryImpl(
    this._remote,
    this._local,
    this._connectivity,
  );

  @override
  Future<MultiResult<Failure, RestaurantSearchResponseEntity>> searchNearby(
    RestaurantSearchParams params,
  ) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.searchNearbyRaw(params),
      );
      if (remote.isSuccess) {
        final json = remote.getSuccess!;
        final items = (json['items'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
        // Cache the list whenever this is a "first page" fetch so the
        // offline restaurants page renders a useful subset.
        if (params.offset == 0) {
          await _local.replaceRestaurants(items);
        }
        return SuccessResult(
          RestaurantSearchResponseEntity(
            total: (json['total'] as num?)?.toInt() ?? items.length,
            items: items.map(RestaurantPublicModel.fromJson).toList(),
          ),
        );
      }
      // Fall through to cache on failure.
    }
    final cached = await _local.getRestaurants();
    if (cached.isEmpty) {
      return FailureResult(InternetConnectionFailure());
    }
    return SuccessResult(
      RestaurantSearchResponseEntity(
        total: cached.length,
        items: cached.map(RestaurantPublicModel.fromJson).toList(),
      ),
    );
  }

  @override
  Future<MultiResult<Failure, RestaurantDetailPublicEntity>> getRestaurant(
    int id,
  ) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.getRestaurantRaw(id),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        await _local.upsertRestaurantDetail(id, raw);
        return SuccessResult(RestaurantDetailPublicModel.fromJson(raw));
      }
    }
    final cached = await _local.getRestaurantDetail(id);
    if (cached != null) {
      return SuccessResult(RestaurantDetailPublicModel.fromJson(cached));
    }
    return FailureResult(InternetConnectionFailure());
  }

  @override
  Future<MultiResult<Failure, List<MenuEntity>>> listMenus(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.listMenusRaw(
          restaurantId,
          limit: limit,
          offset: offset,
        ),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        if (offset == 0) {
          await _local.replaceMenus(restaurantId, raw);
        }
        return SuccessResult(raw.map(MenuModel.fromJson).toList());
      }
    }
    final cached = await _local.getMenus(restaurantId);
    if (cached.isEmpty) {
      return FailureResult(InternetConnectionFailure());
    }
    return SuccessResult(cached.map(MenuModel.fromJson).toList());
  }

  @override
  Future<MultiResult<Failure, List<CategoryEntity>>> listCategories(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  }) {
    // Categories are not cached in v1 — they're small and rarely browsed
    // standalone. Stays online-only.
    return executeWithErrorHandling(
      () => _remote.listCategories(
        restaurantId,
        limit: limit,
        offset: offset,
      ),
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
  }) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.listMenuItemsRaw(
          restaurantId,
          menuId: menuId,
          categoryId: categoryId,
          search: search,
          limit: limit,
          offset: offset,
        ),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        // Don't cache search results — they're query-dependent and would
        // pollute the offline menu browsing view.
        if (search == null && offset == 0) {
          await _local.upsertMenuItems(
            restaurantId,
            raw,
            menuId: menuId,
            categoryId: categoryId,
          );
        }
        return SuccessResult(raw.map(MenuItemModel.fromJson).toList());
      }
    }
    final cached = await _local.getMenuItems(
      restaurantId,
      menuId: menuId,
      categoryId: categoryId,
    );
    if (cached.isEmpty) {
      return FailureResult(InternetConnectionFailure());
    }
    return SuccessResult(cached.map(MenuItemModel.fromJson).toList());
  }

  @override
  Future<MultiResult<Failure, MenuItemEntity>> getMenuItem(int id) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.getMenuItemRaw(id),
      );
      if (remote.isSuccess) {
        return SuccessResult(MenuItemModel.fromJson(remote.getSuccess!));
      }
    }
    final cached = await _local.getMenuItem(id);
    if (cached != null) {
      return SuccessResult(MenuItemModel.fromJson(cached));
    }
    return FailureResult(InternetConnectionFailure());
  }

  @override
  Future<MultiResult<Failure, List<ReviewEntity>>> listReviews(
    int restaurantId, {
    ReviewSort sort = ReviewSort.recent,
    int limit = 20,
    int offset = 0,
  }) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.listReviewsRaw(
          restaurantId,
          sort: sort,
          limit: limit,
          offset: offset,
        ),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        if (offset == 0) {
          await _local.replaceReviews(restaurantId, sort.name, raw);
        }
        return SuccessResult(raw.map(ReviewModel.fromJson).toList());
      }
    }
    final cached = await _local.getReviews(restaurantId, sort.name);
    if (cached.isEmpty) {
      return FailureResult(InternetConnectionFailure());
    }
    return SuccessResult(cached.map(ReviewModel.fromJson).toList());
  }

  @override
  Future<MultiResult<Failure, ReviewSummaryEntity>> getReviewSummary(
    int restaurantId,
  ) {
    // Summary is computed server-side; falling back to a stale value would
    // be misleading. Stays online-only.
    return executeWithErrorHandling(
      () => _remote.getReviewSummary(restaurantId),
    );
  }
}
