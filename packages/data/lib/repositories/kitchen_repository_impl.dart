import 'package:injectable/injectable.dart';
import 'package:data/errors/handle_exception.dart';
import 'package:data/http/rest_client.dart';
import 'package:data/models/kitchen_model.dart';
import 'package:domain/entities/kitchen_entity.dart';
import 'package:domain/errors/exceptions.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/repositories/kitchen_repository.dart';

@LazySingleton(as: KitchenRepository)
class KitchenRepositoryImpl implements KitchenRepository {
  final RestClient rest;

  KitchenRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, List<KitchenEntity>>> getKitchens() {
    return executeWithErrorHandling(() async {
      return await rest.getKitchens();
    });
  }

  @override
  Future<MultiResult<Failure, KitchenEntity>> getKitchen(int kitchenId) {
    return executeWithErrorHandling(() async {
      return await rest.getKitchen(kitchenId);
    });
  }

  @override
  Future<MultiResult<Failure, KitchenEntity>> createKitchen(
    KitchenEntity kitchen,
  ) {
    return executeWithErrorHandling(() async {
      final model = KitchenModel.fromEntity(kitchen);
      return await rest.createKitchen(model);
    });
  }

  @override
  Future<MultiResult<Failure, KitchenEntity>> updateKitchen(
    KitchenEntity kitchen,
  ) {
    return executeWithErrorHandling(() async {
      if (kitchen.id == null) {
        throw ItemNotFoundException('Kitchen ID is required for update');
      }
      final model = KitchenModel.fromEntity(kitchen);
      return await rest.updateKitchen(kitchen.id!, model);
    });
  }

  @override
  Future<MultiResult<Failure, bool>> deleteKitchen(int kitchenId) {
    return executeWithErrorHandling(() async {
      await rest.deleteKitchen(kitchenId);
      return true;
    });
  }

  @override
  Future<MultiResult<Failure, bool>> assignCook(int kitchenId, int userId) {
    return executeWithErrorHandling(() async {
      await rest.assignCookToKitchen(kitchenId, userId);
      return true;
    });
  }

  @override
  Future<MultiResult<Failure, bool>> removeCook(int kitchenId, int userId) {
    return executeWithErrorHandling(() async {
      await rest.removeCookFromKitchen(kitchenId, userId);
      return true;
    });
  }
}
