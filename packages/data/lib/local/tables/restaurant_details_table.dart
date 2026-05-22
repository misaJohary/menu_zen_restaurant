import 'package:drift/drift.dart';

class RestaurantDetailsTable extends Table {
  @override
  String get tableName => 'restaurant_details_cache';

  IntColumn get id => integer()();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
