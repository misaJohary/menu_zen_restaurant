import '../entities/table_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class TablesRepository {
  Future<MultiResult<Failure, List<TableEntity>>> getAll();
  Future<MultiResult<Failure, TableEntity>> add(TableEntity params);
  Future<MultiResult<Failure, TableEntity>> update(TableEntity params);
  Future<MultiResult<Failure, int>> delete(int id);
}
