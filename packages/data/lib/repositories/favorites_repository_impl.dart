import 'package:domain/entities/favorite_entity.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/repositories/favorites_repository.dart';
import 'package:domain/services/connectivity_service.dart';

import '../datasources/customer_favorites_remote_datasource.dart';
import '../errors/handle_exception.dart';
import '../local/datasources/favorites_local_datasource.dart';
import '../models/favorite_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final CustomerFavoritesRemoteDatasource _remote;
  final FavoritesLocalDatasource _local;
  final ConnectivityService _connectivity;

  FavoritesRepositoryImpl(
    this._remote,
    this._local,
    this._connectivity,
  );

  @override
  Future<MultiResult<Failure, List<FavoriteEntity>>> list({
    int limit = 50,
    int offset = 0,
  }) async {
    final online = await _connectivity.isOnline();
    if (online) {
      final remote = await executeWithErrorHandling(
        () => _remote.listRaw(limit: limit, offset: offset),
      );
      if (remote.isSuccess) {
        final raw = remote.getSuccess!;
        if (offset == 0) {
          await _local.replaceFavorites(raw);
        }
        return SuccessResult(raw.map(FavoriteModel.fromJson).toList());
      }
    }
    final cached = await _local.getFavorites();
    if (cached.isEmpty) {
      return SuccessResult(const []);
    }
    return SuccessResult(cached.map(FavoriteModel.fromJson).toList());
  }

  @override
  Future<MultiResult<Failure, FavoriteEntity>> add(int restaurantId) async {
    if (!await _connectivity.isOnline()) {
      return FailureResult(InternetConnectionFailure());
    }
    final result = await executeWithErrorHandling(
      () => _remote.addRaw(restaurantId),
    );
    if (result.isSuccess) {
      final raw = result.getSuccess!;
      await _local.addFavorite(restaurantId, raw);
      return SuccessResult(FavoriteModel.fromJson(raw));
    }
    return FailureResult(result.getError!);
  }

  @override
  Future<MultiResult<Failure, bool>> remove(int restaurantId) async {
    if (!await _connectivity.isOnline()) {
      return FailureResult(InternetConnectionFailure());
    }
    return executeWithErrorHandling(() async {
      await _remote.remove(restaurantId);
      await _local.removeFavorite(restaurantId);
      return true;
    });
  }
}
