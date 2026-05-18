import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:domain/entities/restaurant_detail_public_entity.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:domain/entities/review_summary_entity.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  final PublicRestaurantsRepository _restaurants;

  RestaurantDetailCubit(this._restaurants)
      : super(const RestaurantDetailInitial());

  Future<void> load(int restaurantId) async {
    emit(const RestaurantDetailLoading());

    final results = await Future.wait<MultiResult<dynamic, dynamic>>([
      _restaurants.getRestaurant(restaurantId),
      _restaurants.listCategories(restaurantId),
      _restaurants.listMenuItems(restaurantId),
      _restaurants.listReviews(
        restaurantId,
        sort: ReviewSort.recent,
        limit: 5,
      ),
      _restaurants.getReviewSummary(restaurantId),
    ]);

    final detailResult = results[0];
    if (detailResult.isFailure) {
      emit(
        RestaurantDetailError(
          detailResult.getError?.message ?? 'Could not load restaurant.',
        ),
      );
      return;
    }

    final detail = detailResult.getSuccess as RestaurantDetailPublicEntity;
    final categories = results[1].isSuccess
        ? results[1].getSuccess as List<CategoryEntity>
        : const <CategoryEntity>[];
    final menuItems = results[2].isSuccess
        ? results[2].getSuccess as List<MenuItemEntity>
        : const <MenuItemEntity>[];
    final reviews = results[3].isSuccess
        ? results[3].getSuccess as List<ReviewEntity>
        : const <ReviewEntity>[];
    final summary = results[4].isSuccess
        ? results[4].getSuccess as ReviewSummaryEntity?
        : null;

    emit(
      RestaurantDetailLoaded(
        detail: detail,
        menuByCategory: _groupByCategory(categories, menuItems),
        reviewsPreview: reviews,
        summary: summary,
      ),
    );
  }

  /// Groups [items] by their category id. Categories with no items are
  /// omitted. Items missing a category go into an "Other" bucket so they
  /// never disappear from the menu tab.
  Map<CategoryEntity, List<MenuItemEntity>> _groupByCategory(
    List<CategoryEntity> categories,
    List<MenuItemEntity> items,
  ) {
    final byCategoryId = <int?, List<MenuItemEntity>>{};
    for (final item in items) {
      byCategoryId.putIfAbsent(item.category?.id, () => []).add(item);
    }

    final result = <CategoryEntity, List<MenuItemEntity>>{};
    for (final category in categories) {
      final bucket = byCategoryId[category.id];
      if (bucket != null && bucket.isNotEmpty) {
        result[category] = bucket;
      }
    }
    final unmatched = byCategoryId[null];
    if (unmatched != null && unmatched.isNotEmpty) {
      result[_UncategorizedCategory.instance] = unmatched;
    }
    return result;
  }
}

/// Sentinel category used when the API returns items without a category.
class _UncategorizedCategory extends CategoryEntity {
  static const _UncategorizedCategory instance = _UncategorizedCategory._();
  const _UncategorizedCategory._() : super(id: -1);

  @override
  List<Object?> get props => const [-1];
}
