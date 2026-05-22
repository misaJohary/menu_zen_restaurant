import 'package:drift/drift.dart';

class MenusTable extends Table {
  @override
  String get tableName => 'menus_cache';

  IntColumn get id => integer()();
  IntColumn get restaurantId => integer()();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
