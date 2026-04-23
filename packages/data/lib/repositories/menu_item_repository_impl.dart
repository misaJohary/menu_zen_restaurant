import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:domain/errors/failure.dart';
import 'package:data/errors/handle_exception.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/models/menu_item_model.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:domain/params/menu_item_update_params.dart';
import 'package:domain/repositories/menu_item_repository.dart';

import 'package:data/http/rest_client.dart';
import 'package:data/models/menu_item_translation_model.dart';
import 'package:data/models/menu_item_update_model.dart';

@LazySingleton(as: MenuItemRepository)
class MenuItemRepositoryImpl implements MenuItemRepository {
  final RestClient rest;

  MenuItemRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, MenuItemEntity>> addMenuItem(
    MenuItemEntity params, [
    File? picture,
  ]) {
    return executeWithErrorHandling(() async {
      final model = MenuItemModel.fromEntity(params);
      final res = await rest.createMenuItems(
        model.copyWith(categoryId: model.category?.id),
      );
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, int>> deleteMenuItem(int menuItemId) {
    return executeWithErrorHandling(() async {
      final res = await rest.deleteMenuItems(menuItemId);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, List<MenuItemEntity>>> getMenuItems() {
    return executeWithErrorHandling(() async {
      final res = await rest.getMenuItems();
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuItemEntity>> updateMenuItem(
    MenuItemUpdateParams params,
  ) {
    return executeWithErrorHandling(() async {
      final model = MenuItemUpdateModel(
        id: params.id,
        price: params.price,
        picture: params.picture,
        categoryId: params.categoryId,
        active: params.active,
        translations: params.translations?.cast<MenuItemTranslationModel>(),
        kitchenId: params.kitchenId,
      );
      return await rest.updateMenuItems(model.id, model);
    });
  }
}
