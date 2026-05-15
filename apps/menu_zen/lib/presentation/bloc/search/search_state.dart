part of 'search_bloc.dart';

enum SearchMode { list, map }

@immutable
class SearchState {
  final String query;
  final DiscoveryFilters filters;
  final SearchMode mode;
  final List<RestaurantPublicEntity> items;
  final bool isLoading;
  final bool isPaging;
  final bool hasMore;
  final String? errorMessage;
  final GeoPointEntity origin;
  final bool locationDenied;

  const SearchState({
    this.query = '',
    this.filters = const DiscoveryFilters(),
    this.mode = SearchMode.list,
    this.items = const [],
    this.isLoading = false,
    this.isPaging = false,
    this.hasMore = false,
    this.errorMessage,
    required this.origin,
    this.locationDenied = false,
  });

  bool get isEmpty =>
      !isLoading && errorMessage == null && items.isEmpty;

  SearchState copyWith({
    String? query,
    DiscoveryFilters? filters,
    SearchMode? mode,
    List<RestaurantPublicEntity>? items,
    bool? isLoading,
    bool? isPaging,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    GeoPointEntity? origin,
    bool? locationDenied,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      mode: mode ?? this.mode,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isPaging: isPaging ?? this.isPaging,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      origin: origin ?? this.origin,
      locationDenied: locationDenied ?? this.locationDenied,
    );
  }
}
