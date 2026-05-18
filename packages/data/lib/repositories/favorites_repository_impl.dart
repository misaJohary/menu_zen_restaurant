import 'package:domain/entities/favorite_entity.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/repositories/favorites_repository.dart';

import '../datasources/customer_favorites_remote_datasource.dart';
import '../errors/handle_exception.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final CustomerFavoritesRemoteDatasource _remote;

  FavoritesRepositoryImpl(this._remote);

  @override
  Future<MultiResult<Failure, List<FavoriteEntity>>> list({
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.list(limit: limit, offset: offset),
    );
  }

  @override
  Future<MultiResult<Failure, FavoriteEntity>> add(int restaurantId) {
    return executeWithErrorHandling(() => _remote.add(restaurantId));
  }

  @override
  Future<MultiResult<Failure, bool>> remove(int restaurantId) {
    return executeWithErrorHandling(() async {
      await _remote.remove(restaurantId);
      return true;
    });
  }
}
