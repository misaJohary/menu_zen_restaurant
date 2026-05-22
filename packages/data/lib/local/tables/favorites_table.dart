import 'package:drift/drift.dart';

/// Cached favourites list — the `json` blob holds the full restaurant card
/// so the favourites page can render offline without an extra round trip.
class FavoritesTable extends Table {
  @override
  String get tableName => 'favorites_cache';

  IntColumn get restaurantId => integer()();
  TextColumn get json => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {restaurantId};
}
