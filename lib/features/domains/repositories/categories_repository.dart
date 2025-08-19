import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../datasources/models/category_model.dart';
import '../../datasources/models/menu_model.dart';
import '../entities/category_entity.dart';

abstract class CategoriesRepository {
  Future<MultiResult<Failure, List<CategoryEntity>>> getCategories();

  Future<MultiResult<Failure, CategoryEntity>> addCategory(CategoryModel params);

  Future<MultiResult<Failure, CategoryEntity>> updateCategory(CategoryModel params);

  Future<MultiResult<Failure, CategoryEntity>> deleteCategory(int menuId);
}