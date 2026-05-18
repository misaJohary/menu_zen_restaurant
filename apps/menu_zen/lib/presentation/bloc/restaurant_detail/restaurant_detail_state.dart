part of 'restaurant_detail_cubit.dart';

@immutable
sealed class RestaurantDetailState {
  const RestaurantDetailState();
}

class RestaurantDetailInitial extends RestaurantDetailState {
  const RestaurantDetailInitial();
}

class RestaurantDetailLoading extends RestaurantDetailState {
  const RestaurantDetailLoading();
}

class RestaurantDetailLoaded extends RestaurantDetailState {
  final RestaurantDetailPublicEntity detail;
  final Map<CategoryEntity, List<MenuItemEntity>> menuByCategory;
  final List<ReviewEntity> reviewsPreview;
  final ReviewSummaryEntity? summary;

  const RestaurantDetailLoaded({
    required this.detail,
    required this.menuByCategory,
    required this.reviewsPreview,
    required this.summary,
  });
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;
  const RestaurantDetailError(this.message);
}
