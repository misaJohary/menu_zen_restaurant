import 'package:injectable/injectable.dart';
import 'package:data/models/category_model.dart';
import 'package:domain/entities/category_entity.dart';

import 'package:domain/errors/exceptions.dart';
import 'package:domain/errors/failure.dart';
import 'package:data/errors/handle_exception.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/http/rest_client.dart';
import 'package:domain/repositories/categories_repository.dart';

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
  Future<MultiResult<Failure, CategoryEntity>> addCategory(
    CategoryEntity params,
  ) async {
    return executeWithErrorHandling(() async {
      final model = CategoryModel.fromEntity(params);
      final res = await rest.createCategories(model);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, CategoryEntity>> updateCategory(
    CategoryEntity params,
  ) async {
    return executeWithErrorHandling(() async {
      if (params.id != null) {
        final model = CategoryModel.fromEntity(params);
        final res = await rest.updateCategories(params.id!, model);
        return res;
      }
      throw ItemNotFoundException('Menu ID is required for update');
    });
  }

  @override
  Future<MultiResult<Failure, int>> deleteCategory(int categoryId) async {
    return executeWithErrorHandling(() async {
      final res = await rest.deleteCategories(categoryId);
      return res;
    });
  }
}
