import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../datasources/models/table_model.dart';
import '../entities/table_entity.dart';

abstract class TablesRepository {
  Future<MultiResult<Failure, List<TableEntity>>> getAll();

  Future<MultiResult<Failure, TableEntity>> add(TableModel params);

  Future<MultiResult<Failure, TableEntity>> update(TableModel params);

  Future<MultiResult<Failure, int>> delete(int id);
}