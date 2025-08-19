import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/features/datasources/models/category_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../../domains/repositories/categories_repository.dart';

@LazySingleton(as: CategoriesRepository)
class CategoriesRepositoryImpl implements CategoriesRepository {
  final RestClient rest;

  CategoriesRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, List<CategoryEntity>>> getCategories() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getCategories();
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, CategoryEntity>> addCategory(CategoryModel params) async {
    return executeWithErrorHandling(() async {
      final res = await rest.createCategories(params);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, CategoryEntity>> updateCategory(CategoryModel params) async {
    return executeWithErrorHandling(() async {
      if (params.id != null) {
        final res = await rest.updateCategories(params.id!, params);
        return res;
      }
      throw ItemNotFoundException('Menu ID is required for update');
    });
  }

  @override
  Future<MultiResult<Failure, CategoryEntity>> deleteCategory(int categoryId) async {
    return executeWithErrorHandling(() async {
      print('deeeeelete');
      final res = await rest.deleteCategories(categoryId);
      print('deeeeelete res: $res');
      return res;
    });
  }
}