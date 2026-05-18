import 'package:domain/entities/favorite_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:domain/repositories/favorites_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesInitial());

  Future<void> load() async {
    emit(const FavoritesLoading());
    final result = await _repository.list();
    if (result.isSuccess) {
      emit(FavoritesLoaded(items: result.getSuccess ?? const []));
    } else {
      emit(
        FavoritesError(
          result.getError?.message ?? 'Could not load your favorites.',
        ),
      );
    }
  }

  Future<void> refresh() => load();

  /// Clears state on sign-out so the next session starts fresh.
  void reset() => emit(const FavoritesInitial());

  bool isFavorite(int restaurantId) =>
      state.restaurantIds.contains(restaurantId);

  /// Optimistically adds the restaurant. Rolls back on failure.
  Future<void> add(RestaurantPublicEntity restaurant) async {
    final current = _currentLoaded();
    if (current.pending.contains(restaurant.id)) return;
    if (current.restaurantIds.contains(restaurant.id)) return;

    final placeholder = FavoriteEntity(
      id: -restaurant.id,
      createdAt: DateTime.now(),
      restaurant: restaurant,
    );
    emit(
      current.copyWith(
        items: [placeholder, ...current.items],
        pending: {...current.pending, restaurant.id},
        clearError: true,
      ),
    );

    final result = await _repository.add(restaurant.id);
    final after = _currentLoaded();
    final nextPending = {...after.pending}..remove(restaurant.id);

    if (result.isSuccess && result.getSuccess != null) {
      final added = result.getSuccess!;
      final replaced = after.items
          .map((item) => item.restaurant.id == restaurant.id ? added : item)
          .toList();
      emit(after.copyWith(items: replaced, pending: nextPending));
    } else {
      final rolled = after.items
          .where((item) => item.restaurant.id != restaurant.id)
          .toList();
      emit(
        after.copyWith(
          items: rolled,
          pending: nextPending,
          lastErrorMessage:
              result.getError?.message ?? 'Could not add to favorites.',
        ),
      );
    }
  }

  /// Optimistically removes the restaurant. Rolls back on failure.
  Future<void> remove(int restaurantId) async {
    final current = _currentLoaded();
    if (current.pending.contains(restaurantId)) return;
    final removed = current.items.firstWhere(
      (item) => item.restaurant.id == restaurantId,
      orElse: () => _none,
    );
    if (identical(removed, _none)) return;

    emit(
      current.copyWith(
        items: current.items
            .where((item) => item.restaurant.id != restaurantId)
            .toList(),
        pending: {...current.pending, restaurantId},
        clearError: true,
      ),
    );

    final result = await _repository.remove(restaurantId);
    final after = _currentLoaded();
    final nextPending = {...after.pending}..remove(restaurantId);

    if (result.isSuccess) {
      emit(after.copyWith(pending: nextPending));
    } else {
      // Insert back in original position by createdAt-desc order.
      final restored = [...after.items, removed]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(
        after.copyWith(
          items: restored,
          pending: nextPending,
          lastErrorMessage:
              result.getError?.message ?? 'Could not remove from favorites.',
        ),
      );
    }
  }

  Future<void> toggle(RestaurantPublicEntity restaurant) async {
    if (isFavorite(restaurant.id)) {
      await remove(restaurant.id);
    } else {
      await add(restaurant);
    }
  }

  FavoritesLoaded _currentLoaded() {
    final s = state;
    if (s is FavoritesLoaded) return s;
    final loaded = const FavoritesLoaded();
    emit(loaded);
    return loaded;
  }

  static final FavoriteEntity _none = FavoriteEntity(
    id: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    restaurant: const RestaurantPublicEntity(
      id: -1,
      name: '',
      phone: '',
      email: '',
      city: '',
    ),
  );
}
