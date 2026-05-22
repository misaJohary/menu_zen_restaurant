import 'package:drift/drift.dart';

class MenuItemsTable extends Table {
  @override
  String get tableName => 'menu_items_cache';

  IntColumn get id => integer()();
  IntColumn get restaurantId => integer()();
  IntColumn get menuId => integer().nullable()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
