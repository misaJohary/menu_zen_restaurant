import 'dart:async';

import 'package:domain/entities/discovery_filters.dart';
import 'package:domain/entities/geo_point_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:domain/params/restaurant_search_params.dart';
import 'package:domain/repositories/geolocation_repository.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

const _kFallbackPosition = GeoPointEntity(lat: -18.8792, long: 47.5079);
const _kPageSize = 20;
const _kDebounce = Duration(milliseconds: 300);

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final PublicRestaurantsRepository _restaurants;
  final GeolocationRepository _geo;
  Timer? _debounce;

  SearchBloc({
    required PublicRestaurantsRepository restaurants,
    required GeolocationRepository geo,
  })  : _restaurants = restaurants,
        _geo = geo,
        super(const SearchState(origin: _kFallbackPosition)) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFiltersChanged>(_onFiltersChanged);
    on<SearchModeToggled>(_onModeToggled);
    on<SearchScrolledEnd>(_onScrolledEnd);
    on<SearchRefreshed>(_onRefreshed);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> _onStarted(SearchStarted event, Emitter<SearchState> emit) async {
    final (position, denied) = await _resolveOrigin();
    emit(
      state.copyWith(
        origin: position,
        locationDenied: denied,
        query: event.initialQuery ?? state.query,
      ),
    );
    await _fetch(emit, reset: true);
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    _debounce?.cancel();
    emit(state.copyWith(query: event.query));
    _debounce = Timer(_kDebounce, () => add(const SearchRefreshed()));
  }

  Future<void> _onFiltersChanged(
    SearchFiltersChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(filters: event.filters));
    await _fetch(emit, reset: true);
  }

  void _onModeToggled(SearchModeToggled event, Emitter<SearchState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  Future<void> _onScrolledEnd(
    SearchScrolledEnd event,
    Emitter<SearchState> emit,
  ) async {
    if (!state.hasMore || state.isPaging || state.isLoading) return;
    await _fetch(emit, reset: false);
  }

  Future<void> _onRefreshed(
    SearchRefreshed event,
    Emitter<SearchState> emit,
  ) async {
    await _fetch(emit, reset: true);
  }

  Future<void> _fetch(Emitter<SearchState> emit, {required bool reset}) async {
    if (reset) {
      emit(state.copyWith(isLoading: true, clearError: true));
    } else {
      emit(state.copyWith(isPaging: true));
    }

    final params = RestaurantSearchParams(
      lat: state.origin.lat,
      long: state.origin.long,
      radiusKm: state.filters.radiusKm,
      q: state.query.isEmpty ? null : state.query,
      type: state.filters.type,
      limit: _kPageSize,
      offset: reset ? 0 : state.items.length,
    );

    final result = await _restaurants.searchNearby(params);

    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoading: false,
          isPaging: false,
          errorMessage: result.getError?.message ?? 'Search failed',
        ),
      );
      return;
    }

    final response = result.getSuccess!;
    final items = reset ? response.items : [...state.items, ...response.items];

    emit(
      state.copyWith(
        items: items,
        isLoading: false,
        isPaging: false,
        hasMore: items.length < response.total,
        clearError: true,
      ),
    );
  }

  Future<(GeoPointEntity, bool denied)> _resolveOrigin() async {
    final status = await _geo.permissionStatus();
    if (status == LocationPermissionStatus.granted) {
      final result = await _geo.currentPosition();
      if (result.isSuccess) return (result.getSuccess!, false);
    } else {
      final requested = await _geo.requestPermission();
      if (requested == LocationPermissionStatus.granted) {
        final result = await _geo.currentPosition();
        if (result.isSuccess) return (result.getSuccess!, false);
      }
    }
    return (_kFallbackPosition, true);
  }
}
