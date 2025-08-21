import 'dart:io';

import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../datasources/models/menu_item_model.dart';
import '../entities/menu_item_entity.dart';

abstract class MenuItemRepository{
  Future<MultiResult<Failure, List<MenuItemEntity>>> getMenuItems();
  Future<MultiResult<Failure, MenuItemEntity>> addMenuItem(MenuItemModel params, File picture);
  Future<MultiResult<Failure, MenuItemEntity>> updateMenuItem(MenuItemModel params);
  Future<MultiResult<Failure, MenuItemEntity>> deleteMenuItem(int menuItemId);
}