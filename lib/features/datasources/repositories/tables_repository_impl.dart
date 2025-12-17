import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/features/datasources/models/table_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/table_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/tables_repository.dart';

import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/rest_client.dart';

@LazySingleton(as: TablesRepository)
class TablesRepositoryImpl implements TablesRepository {
  final RestClient rest;

  TablesRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, TableEntity>> add(TableModel params) async {
    return executeWithErrorHandling(() async {
      final res = await rest.createTable(params);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, int>> delete(int id) async {
    return executeWithErrorHandling(() async {
      final res = await rest.deleteTable(id);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, List<TableEntity>>> getAll() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getTables();
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, TableEntity>> update(TableModel params) async {
    return executeWithErrorHandling(() async {
      final res = await rest.updateTables(params.id!, params);
      return res;
    });
  }
}
