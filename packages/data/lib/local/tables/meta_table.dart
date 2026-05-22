import 'package:drift/drift.dart';

/// Key/value store for per-resource sync metadata
/// (e.g. last successful refresh timestamps).
class MetaTable extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
