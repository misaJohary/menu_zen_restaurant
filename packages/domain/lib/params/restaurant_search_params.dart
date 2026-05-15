import 'package:equatable/equatable.dart';

import '../entities/restaurant_public_entity.dart';

class RestaurantSearchParams extends Equatable {
  final double lat;
  final double long;
  final double? radiusKm;
  final String? q;
  final RestaurantType? type;
  final int limit;
  final int offset;

  const RestaurantSearchParams({
    required this.lat,
    required this.long,
    this.radiusKm,
    this.q,
    this.type,
    this.limit = 20,
    this.offset = 0,
  });

  RestaurantSearchParams copyWith({
    double? lat,
    double? long,
    double? radiusKm,
    String? q,
    RestaurantType? type,
    int? limit,
    int? offset,
  }) {
    return RestaurantSearchParams(
      lat: lat ?? this.lat,
      long: long ?? this.long,
      radiusKm: radiusKm ?? this.radiusKm,
      q: q ?? this.q,
      type: type ?? this.type,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [lat, long, radiusKm, q, type, limit, offset];
}
