import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/errors/handle_exception.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/features/datasources/models/menu_item_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/menu_item_repository.dart';

import '../../../core/http_connexion/rest_client.dart';

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
        name: params.name,
        price: params.price,
        //isAvailable: params.isAvailable ?? true,
        description: params.description,
        categoryId: params.category.id!,
        menus: params.menus.map((menu) => menu.id!).toList().join(','),
        picture: picture,
      );
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuItemEntity>> deleteMenuItem(int menuItemId) {
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
    MenuItemModel params,
  ) {
    // TODO: implement updateMenuItem
    throw UnimplementedError();
  }
}
