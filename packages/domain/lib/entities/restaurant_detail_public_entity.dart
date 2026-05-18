import 'restaurant_public_entity.dart';

/// Carries the "next opening" hint returned alongside detail when the
/// restaurant is currently closed.
class NextOpeningEntity {
  /// `"today"`, `"tomorrow"`, or a weekday name (`"Monday"`..`"Sunday"`).
  final String day;
  final String time;

  const NextOpeningEntity({required this.day, required this.time});
}

class RestaurantDetailPublicEntity extends RestaurantPublicEntity {
  final double? avgRating;
  final int reviewCount;
  final bool isOpenNow;
  final NextOpeningEntity? nextOpening;

  const RestaurantDetailPublicEntity({
    required super.id,
    required super.name,
    super.description,
    super.type,
    super.languages,
    super.logo,
    super.cover,
    super.pictures,
    super.socialMedia,
    super.openingHours,
    required super.phone,
    required super.email,
    required super.city,
    super.lat,
    super.long,
    super.disabled,
    super.distanceKm,
    this.avgRating,
    this.reviewCount = 0,
    this.isOpenNow = false,
    this.nextOpening,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    avgRating,
    reviewCount,
    isOpenNow,
    nextOpening?.day,
    nextOpening?.time,
  ];
}
