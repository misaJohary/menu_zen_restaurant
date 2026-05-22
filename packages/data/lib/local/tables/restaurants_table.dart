import 'package:drift/drift.dart';

/// Cached snapshots of restaurants surfaced by the public discovery list.
/// Stored as JSON blobs because we only ever render them — the only fields
/// we need to query on are id and the cache age.
class RestaurantsTable extends Table {
  @override
  String get tableName => 'restaurants_cache';

  IntColumn get id => integer()();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
