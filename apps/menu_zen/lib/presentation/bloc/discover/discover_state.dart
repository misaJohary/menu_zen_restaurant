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
