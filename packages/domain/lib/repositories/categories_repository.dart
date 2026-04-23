import '../entities/category_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class CategoriesRepository {
  Future<MultiResult<Failure, List<CategoryEntity>>> getCategories();

  Future<MultiResult<Failure, CategoryEntity>> addCategory(
    CategoryEntity params,
  );

  Future<MultiResult<Failure, CategoryEntity>> updateCategory(
    CategoryEntity params,
  );

  Future<MultiResult<Failure, int>> deleteCategory(int menuId);
}
