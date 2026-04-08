import '../entities/menu_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class MenusRepository {
  Future<MultiResult<Failure, List<MenuEntity>>> getMenus();
  Future<MultiResult<Failure, MenuEntity>> addMenu(MenuEntity params);
  Future<MultiResult<Failure, MenuEntity>> updateMenu(MenuEntity params);
  Future<MultiResult<Failure, int>> deleteMenu(int menuId);
}
