import 'package:equatable/equatable.dart';

import 'restaurant_public_entity.dart';

class DiscoveryFilters extends Equatable {
  final String? query;
  final RestaurantType? type;
  final double? radiusKm;
  final Set<String> dietary;
  final Set<String> capabilities;

  const DiscoveryFilters({
    this.query,
    this.type,
    this.radiusKm,
    this.dietary = const {},
    this.capabilities = const {},
  });

  DiscoveryFilters copyWith({
    String? query,
    RestaurantType? type,
    double? radiusKm,
    Set<String>? dietary,
    Set<String>? capabilities,
    bool clearQuery = false,
    bool clearType = false,
    bool clearRadius = false,
  }) {
    return DiscoveryFilters(
      query: clearQuery ? null : (query ?? this.query),
      type: clearType ? null : (type ?? this.type),
      radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
      dietary: dietary ?? this.dietary,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  bool get isEmpty =>
      (query == null || query!.isEmpty) &&
      type == null &&
      radiusKm == null &&
      dietary.isEmpty &&
      capabilities.isEmpty;

  int get activeCount {
    var n = 0;
    if (query != null && query!.isNotEmpty) n++;
    if (type != null) n++;
    if (radiusKm != null) n++;
    if (dietary.isNotEmpty) n++;
    if (capabilities.isNotEmpty) n++;
    return n;
  }

  @override
  List<Object?> get props => [query, type, radiusKm, dietary, capabilities];
}
