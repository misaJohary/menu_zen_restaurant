import 'package:drift/drift.dart';

class ReviewsTable extends Table {
  @override
  String get tableName => 'reviews_cache';

  IntColumn get id => integer()();
  IntColumn get restaurantId => integer()();
  TextColumn get sort => text().withDefault(const Constant('recent'))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, sort};
}
