import '../entities/category_entity.dart';
import '../entities/menu_entity.dart';
import '../entities/menu_item_entity.dart';
import '../entities/restaurant_detail_public_entity.dart';
import '../entities/restaurant_search_response.dart';
import '../entities/review_entity.dart';
import '../entities/review_summary_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/restaurant_search_params.dart';

enum ReviewSort { recent, top, low }

abstract class PublicRestaurantsRepository {
  Future<MultiResult<Failure, RestaurantSearchResponseEntity>> searchNearby(
    RestaurantSearchParams params,
  );

  Future<MultiResult<Failure, RestaurantDetailPublicEntity>> getRestaurant(
    int id,
  );

  Future<MultiResult<Failure, List<MenuEntity>>> listMenus(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, List<CategoryEntity>>> listCategories(
    int restaurantId, {
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, List<MenuItemEntity>>> listMenuItems(
    int restaurantId, {
    int? menuId,
    int? categoryId,
    String? search,
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, MenuItemEntity>> getMenuItem(int id);

  Future<MultiResult<Failure, List<ReviewEntity>>> listReviews(
    int restaurantId, {
    ReviewSort sort = ReviewSort.recent,
    int limit = 20,
    int offset = 0,
  });

  Future<MultiResult<Failure, ReviewSummaryEntity>> getReviewSummary(
    int restaurantId,
  );
}
