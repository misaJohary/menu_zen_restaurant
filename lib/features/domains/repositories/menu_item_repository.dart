import 'dart:io';

import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../datasources/models/menu_item_model.dart';
import '../../datasources/models/menu_item_update_model.dart';
import '../entities/menu_item_entity.dart';

abstract class MenuItemRepository{
  Future<MultiResult<Failure, List<MenuItemEntity>>> getMenuItems();
  Future<MultiResult<Failure, MenuItemEntity>> addMenuItem(MenuItemModel params, File picture);
  Future<MultiResult<Failure, MenuItemEntity>> updateMenuItem(MenuItemUpdateModel params);
  //Future<MultiResult<Failure, MenuItemEntity>> changeMenuItemAvalaibility(bool active);
  Future<MultiResult<Failure, int>> deleteMenuItem(int menuItemId);
}