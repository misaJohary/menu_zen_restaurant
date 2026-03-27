import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/errors/handle_exception.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/features/datasources/models/menu_item_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/menu_item_repository.dart';

import '../../../core/http_connexion/rest_client.dart';
import '../models/menu_item_update_model.dart';

@LazySingleton(as: MenuItemRepository)
class MenuItemRepositoryImpl implements MenuItemRepository {
  final RestClient rest;

  MenuItemRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, MenuItemEntity>> addMenuItem(
    MenuItemModel params,
    File picture,
  ) {
    return executeWithErrorHandling(() async {
      final res = await rest.createMenuItems(
        params.copyWith(categoryId: params.category?.id),
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
    MenuItemUpdateModel params,
  ) {
    return executeWithErrorHandling(() async {
      return await rest.updateMenuItems(params.id, params);
    });
  }

  // @override
  // Future<MultiResult<Failure, MenuItemEntity>> changeMenuItemAvalaibility(bool active) async {
  //   return executeWithErrorHandling(() async {
  //     return await rest.updateMenuItems(
  //       params.id!,
  //       params.copyWith(categoryId: params.category?.id),
  //     );
  //   });
  // }
}
