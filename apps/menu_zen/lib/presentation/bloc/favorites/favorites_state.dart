part of 'favorites_cubit.dart';

@immutable
sealed class FavoritesState {
  const FavoritesState();

  /// IDs of restaurants in the loaded set. Empty until [FavoritesLoaded].
  Set<int> get restaurantIds => const {};
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteEntity> items;

  /// Restaurant IDs whose toggle is currently in flight. Used to disable the
  /// heart button briefly so the user cannot spam-tap the same row.
  final Set<int> pending;

  /// Surfaces the last toggle error; cleared on the next successful action.
  final String? lastErrorMessage;

  const FavoritesLoaded({
    this.items = const [],
    this.pending = const {},
    this.lastErrorMessage,
  });

  @override
  Set<int> get restaurantIds => {for (final f in items) f.restaurant.id};

  FavoritesLoaded copyWith({
    List<FavoriteEntity>? items,
    Set<int>? pending,
    String? lastErrorMessage,
    bool clearError = false,
  }) {
    return FavoritesLoaded(
      items: items ?? this.items,
      pending: pending ?? this.pending,
      lastErrorMessage: clearError
          ? null
          : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
}
