import 'package:drift/drift.dart';

class CustomerOrdersTable extends Table {
  @override
  String get tableName => 'customer_orders_cache';

  IntColumn get id => integer()();
  IntColumn get restaurantId => integer()();
  TextColumn get status => text().nullable()();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
