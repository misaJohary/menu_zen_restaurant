import 'package:domain/entities/geo_point_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:domain/params/restaurant_search_params.dart';
import 'package:domain/repositories/geolocation_repository.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:domain/services/connectivity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'discover_state.dart';

/// Default location used when the user denies the location permission.
/// Antananarivo city center — a reasonable starting point given launch
/// scope (open question §2 in IMPLEMENTATION_PLAN.md).
const _kFallbackPosition = GeoPointEntity(lat: -18.8792, long: 47.5079);
const _kFallbackCity = 'Antananarivo';

class DiscoverCubit extends Cubit<DiscoverState> {
  final PublicRestaurantsRepository _restaurants;
  final GeolocationRepository _geo;
  final ConnectivityService _connectivity;

  DiscoverCubit({
    required PublicRestaurantsRepository restaurants,
    required GeolocationRepository geo,
    required ConnectivityService connectivity,
  })  : _restaurants = restaurants,
        _geo = geo,
        _connectivity = connectivity,
        super(const DiscoverInitial());

  Future<void> load() async {
    emit(const DiscoverLoading());

    final (position, locationDenied) = await _resolvePosition();

    final nearResult = await _restaurants.searchNearby(
      RestaurantSearchParams(
        lat: position.lat,
        long: position.long,
        radiusKm: 10,
        limit: 10,
      ),
    );

    if (nearResult.isFailure) {
      // Disambiguate "no network" from a real server error so the page can
      // show a friendlier empty state instead of a kitchen-down message.
      if (!await _connectivity.isOnline()) {
        emit(const DiscoverOffline());
        return;
      }
      emit(DiscoverError(nearResult.getError?.message ?? 'Something went wrong'));
      return;
    }
    final near = nearResult.getSuccess!.items;

    // Trending: same call without radius, larger limit. Real ranking is
    // a backend follow-up.
    // TODO(api): swap to a server-side `sort=popular` when available.
    final trendingResult = await _restaurants.searchNearby(
      RestaurantSearchParams(
        lat: position.lat,
        long: position.long,
        limit: 12,
      ),
    );

    final trending = trendingResult.isSuccess
        ? trendingResult.getSuccess!.items
        : <RestaurantPublicEntity>[];

    // Picked for you: pick the nearest restaurant the user hasn't seen.
    // Cold-start fallback is the first non-near trending result.
    // TODO(api): replace with a real `/recommended` endpoint.
    final nearIds = near.map((r) => r.id).toSet();
    final pick = trending.firstWhere(
      (r) => !nearIds.contains(r.id),
      orElse: () => near.isNotEmpty ? near.first : (
        trending.isNotEmpty ? trending.first : _emptyPick
      ),
    );

    emit(
      DiscoverLoaded(
        near: near,
        trending: trending,
        pick: pick.id == -1 ? null : pick,
        pickIsNew: nearIds.isEmpty,
        city: locationDenied ? _kFallbackCity : null,
        locationDenied: locationDenied,
      ),
    );
  }

  Future<(GeoPointEntity, bool denied)> _resolvePosition() async {
    final status = await _geo.permissionStatus();
    if (status == LocationPermissionStatus.granted) {
      final result = await _geo.currentPosition();
      if (result.isSuccess) return (result.getSuccess!, false);
      return (_kFallbackPosition, true);
    }

    final requested = await _geo.requestPermission();
    if (requested != LocationPermissionStatus.granted) {
      return (_kFallbackPosition, true);
    }

    final result = await _geo.currentPosition();
    if (result.isSuccess) return (result.getSuccess!, false);
    return (_kFallbackPosition, true);
  }
}

const _emptyPick = RestaurantPublicEntity(
  id: -1,
  name: '',
  phone: '',
  email: '',
  city: '',
);
