import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../datasources/models/menu_model.dart';
import '../entities/menu_entity.dart';

abstract class MenusRepository{
  Future<MultiResult<Failure, List<MenuEntity>>> getMenus();
  Future<MultiResult<Failure, MenuEntity>> addMenu(MenuModel params);
  Future<MultiResult<Failure, MenuEntity>> updateMenu(MenuModel params);
  Future<MultiResult<Failure, MenuEntity>> deleteMenu(int menuId);
}