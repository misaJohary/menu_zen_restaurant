import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../cache_policy.dart';

class FavoritesLocalDatasource {
  FavoritesLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final cutoff =
        DateTime.now().toUtc().subtract(CachePolicy.favoritesTtl);
    final query = _db.select(_db.favoritesTable)
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(cutoff));
    final rows = await query.get();
    return rows
        .map((r) => jsonDecode(r.json) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<Set<int>> getFavoriteIds() async {
    final query = _db.selectOnly(_db.favoritesTable)
      ..addColumns([_db.favoritesTable.restaurantId]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.favoritesTable.restaurantId)!)
        .toSet();
  }

  Future<void> replaceFavorites(List<Map<String, dynamic>> rawList) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await _db.delete(_db.favoritesTable).go();
      await _db.batch((b) {
        for (final raw in rawList) {
          final id = (raw['id'] as num?)?.toInt() ??
              (raw['restaurant_id'] as num?)?.toInt();
          if (id == null) continue;
          b.insert(
            _db.favoritesTable,
            FavoritesTableCompanion.insert(
              restaurantId: Value(id),
              json: jsonEncode(raw),
              cachedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  Future<void> addFavorite(int restaurantId, Map<String, dynamic> raw) async {
    await _db.into(_db.favoritesTable).insertOnConflictUpdate(
          FavoritesTableCompanion.insert(
            restaurantId: Value(restaurantId),
            json: jsonEncode(raw),
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> removeFavorite(int restaurantId) async {
    await (_db.delete(_db.favoritesTable)
          ..where((t) => t.restaurantId.equals(restaurantId)))
        .go();
  }

  Future<void> clearAll() => _db.delete(_db.favoritesTable).go();
}
