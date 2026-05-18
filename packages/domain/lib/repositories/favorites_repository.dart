import '../entities/favorite_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class FavoritesRepository {
  Future<MultiResult<Failure, List<FavoriteEntity>>> list({
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, FavoriteEntity>> add(int restaurantId);

  Future<MultiResult<Failure, bool>> remove(int restaurantId);
}
