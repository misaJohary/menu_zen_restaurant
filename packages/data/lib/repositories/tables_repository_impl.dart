import 'package:injectable/injectable.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/models/table_model.dart';
import 'package:domain/entities/table_entity.dart';
import 'package:domain/repositories/tables_repository.dart';

import 'package:data/errors/handle_exception.dart';
import 'package:data/http/rest_client.dart';

@LazySingleton(as: TablesRepository)
class TablesRepositoryImpl implements TablesRepository {
  final RestClient rest;

  TablesRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, TableEntity>> add(TableEntity params) async {
    return executeWithErrorHandling(() async {
      final model = TableModel.fromEntity(params);
      final res = await rest.createTable(model);
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
  Future<MultiResult<Failure, TableEntity>> update(TableEntity params) async {
    return executeWithErrorHandling(() async {
      final model = TableModel.fromEntity(params);
      final res = await rest.updateTables(model.id!, model);
      return res;
    });
  }
}
