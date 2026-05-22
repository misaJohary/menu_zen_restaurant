part of 'discover_cubit.dart';

@immutable
sealed class DiscoverState {
  const DiscoverState();
}

class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();
}

class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();
}

class DiscoverLoaded extends DiscoverState {
  final List<RestaurantPublicEntity> near;
  final List<RestaurantPublicEntity> trending;
  final RestaurantPublicEntity? pick;
  final bool pickIsNew;
  final String? city;
  final bool locationDenied;

  const DiscoverLoaded({
    required this.near,
    required this.trending,
    required this.pick,
    required this.pickIsNew,
    this.city,
    this.locationDenied = false,
  });
}

class DiscoverError extends DiscoverState {
  final String message;
  const DiscoverError(this.message);
}

/// Device is offline and the local cache has nothing to show yet (first
/// run while offline). Distinct from `DiscoverError` so the UI can offer a
/// friendlier "connect to load restaurants" empty state instead of a
/// generic server-error message.
class DiscoverOffline extends DiscoverState {
  const DiscoverOffline();
}
