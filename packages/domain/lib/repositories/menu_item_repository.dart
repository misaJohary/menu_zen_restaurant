import 'dart:io';

import '../entities/menu_item_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/menu_item_update_params.dart';

abstract class MenuItemRepository {
  Future<MultiResult<Failure, List<MenuItemEntity>>> getMenuItems();
  Future<MultiResult<Failure, MenuItemEntity>> addMenuItem(
    MenuItemEntity params, [
    File? picture,
  ]);
  Future<MultiResult<Failure, MenuItemEntity>> updateMenuItem(
    MenuItemUpdateParams params,
  );
  Future<MultiResult<Failure, int>> deleteMenuItem(int menuItemId);
}
