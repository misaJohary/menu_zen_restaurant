import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/core/http_connexion/rest_client.dart';
import 'package:menu_zen_restaurant/core/services/db_service.dart';
import 'package:menu_zen_restaurant/features/datasources/models/menu_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/menus_repository.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/handle_exception.dart';

@LazySingleton(as: MenusRepository)
class MenusRepositoryImpl implements MenusRepository {
  final RestClient rest;
  final DbService db;

  MenusRepositoryImpl({required this.rest, required this.db});

  @override
  Future<MultiResult<Failure, List<MenuEntity>>> getMenus() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getMenus();
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuEntity>> addMenu(MenuModel params) async {
    return executeWithErrorHandling(() async {
      final res = await rest.createMenus(params);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuEntity>> deleteMenu(int menuId) async {
    return executeWithErrorHandling(() async {
      final res = await rest.deleteMenus(menuId);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, MenuEntity>> updateMenu(MenuModel params) {
    return executeWithErrorHandling(() async {
      if (params.id != null) {
        final res = await rest.updateMenus(params.id!, params);
        return res;
      }
      throw ItemNotFoundException('Menu ID is required for update');
    });
  }
}
