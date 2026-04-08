import 'package:injectable/injectable.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/http/rest_client.dart';
import 'package:data/models/menu_model.dart';
import 'package:domain/entities/menu_entity.dart';
import 'package:domain/repositories/menus_repository.dart';

import 'package:domain/errors/exceptions.dart';
import 'package:data/errors/handle_exception.dart';

@LazySingleton(as: MenusRepository)
class MenusRepositoryImpl implements MenusRepository {
  final RestClient rest;

  MenusRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, List<MenuEntity>>> getMenus() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getMenus();
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuEntity>> addMenu(MenuEntity params) async {
    return executeWithErrorHandling(() async {
      final model = MenuModel.fromEntity(params);
      final res = await rest.createMenus(model);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, int>> deleteMenu(int menuId) async {
    return executeWithErrorHandling(() async {
      final res = await rest.deleteMenus(menuId);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuEntity>> updateMenu(MenuEntity params) {
    return executeWithErrorHandling(() async {
      if (params.id != null) {
        final model = MenuModel.fromEntity(params);
        final res = await rest.updateMenus(params.id!, model);
        return res;
      }
      throw ItemNotFoundException('Menu ID is required for update');
    });
  }
}
