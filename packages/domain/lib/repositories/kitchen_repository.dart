import '../entities/kitchen_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class KitchenRepository {
  Future<MultiResult<Failure, List<KitchenEntity>>> getKitchens();

  Future<MultiResult<Failure, KitchenEntity>> getKitchen(int kitchenId);

  Future<MultiResult<Failure, KitchenEntity>> createKitchen(
    KitchenEntity kitchen,
  );

  Future<MultiResult<Failure, KitchenEntity>> updateKitchen(
    KitchenEntity kitchen,
  );

  Future<MultiResult<Failure, bool>> deleteKitchen(int kitchenId);

  Future<MultiResult<Failure, bool>> assignCook(int kitchenId, int userId);

  Future<MultiResult<Failure, bool>> removeCook(int kitchenId, int userId);
}
