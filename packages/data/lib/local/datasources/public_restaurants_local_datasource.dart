import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../cache_policy.dart';

/// Local cache for the public/discover read paths.
///
/// Stores raw JSON returned by the API so we don't need inverse `toJson`
/// methods on every model. The repository parses the cached JSON via the
/// existing `fromJson` factories.
class PublicRestaurantsLocalDatasource {
  PublicRestaurantsLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------- Restaurants list ------------------------------------------
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final query = _db.select(_db.restaurantsTable)
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(_cutoff()));
    final rows = await query.get();
    return rows
        .map((r) => jsonDecode(r.json) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<void> replaceRestaurants(List<Map<String, dynamic>> items) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await _db.delete(_db.restaurantsTable).go();
      await _db.batch((b) {
        for (final raw in items) {
          final id = (raw['id'] as num?)?.toInt();
          if (id == null) continue;
          b.insert(
            _db.restaurantsTable,
            RestaurantsTableCompanion.insert(
              id: Value(id),
              json: jsonEncode(raw),
              cachedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  // ---------- Restaurant detail -----------------------------------------
  Future<Map<String, dynamic>?> getRestaurantDetail(int id) async {
    final query = _db.select(_db.restaurantDetailsTable)
      ..where((t) => t.id.equals(id))
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(_cutoff()));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return jsonDecode(row.json) as Map<String, dynamic>;
  }

  Future<void> upsertRestaurantDetail(
    int id,
    Map<String, dynamic> raw,
  ) async {
    await _db.into(_db.restaurantDetailsTable).insertOnConflictUpdate(
          RestaurantDetailsTableCompanion.insert(
            id: Value(id),
            json: jsonEncode(raw),
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  // ---------- Menus -----------------------------------------------------
  Future<List<Map<String, dynamic>>> getMenus(int restaurantId) async {
    final query = _db.select(_db.menusTable)
      ..where((t) => t.restaurantId.equals(restaurantId))
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(_cutoff()));
    final rows = await query.get();
    return rows
        .map((r) => jsonDecode(r.json) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<void> replaceMenus(
    int restaurantId,
    List<Map<String, dynamic>> items,
  ) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.delete(_db.menusTable)
            ..where((t) => t.restaurantId.equals(restaurantId)))
          .go();
      await _db.batch((b) {
        for (final raw in items) {
          final id = (raw['id'] as num?)?.toInt();
          if (id == null) continue;
          b.insert(
            _db.menusTable,
            MenusTableCompanion.insert(
              id: Value(id),
              restaurantId: restaurantId,
              json: jsonEncode(raw),
              cachedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  // ---------- Menu items ------------------------------------------------
  Future<List<Map<String, dynamic>>> getMenuItems(
    int restaurantId, {
    int? menuId,
    int? categoryId,
  }) async {
    final query = _db.select(_db.menuItemsTable)
      ..where((t) => t.restaurantId.equals(restaurantId))
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(_cutoff()));
    if (menuId != null) {
      query.where((t) => t.menuId.equals(menuId));
    }
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    final rows = await query.get();
    return rows
        .map((r) => jsonDecode(r.json) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<void> upsertMenuItems(
    int restaurantId,
    List<Map<String, dynamic>> items, {
    int? menuId,
    int? categoryId,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.batch((b) {
      for (final raw in items) {
        final id = (raw['id'] as num?)?.toInt();
        if (id == null) continue;
        b.insert(
          _db.menuItemsTable,
          MenuItemsTableCompanion.insert(
            id: Value(id),
            restaurantId: restaurantId,
            menuId: Value(menuId ?? (raw['menu_id'] as num?)?.toInt()),
            categoryId:
                Value(categoryId ?? (raw['category_id'] as num?)?.toInt()),
            json: jsonEncode(raw),
            cachedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<Map<String, dynamic>?> getMenuItem(int id) async {
    final query = _db.select(_db.menuItemsTable)
      ..where((t) => t.id.equals(id))
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(_cutoff()));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return jsonDecode(row.json) as Map<String, dynamic>;
  }

  // ---------- Reviews ---------------------------------------------------
  Future<List<Map<String, dynamic>>> getReviews(
    int restaurantId,
    String sort,
  ) async {
    final query = _db.select(_db.reviewsTable)
      ..where((t) => t.restaurantId.equals(restaurantId))
      ..where((t) => t.sort.equals(sort))
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(_cutoff()))
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    final rows = await query.get();
    return rows
        .map((r) => jsonDecode(r.json) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<void> replaceReviews(
    int restaurantId,
    String sort,
    List<Map<String, dynamic>> items,
  ) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.delete(_db.reviewsTable)
            ..where((t) => t.restaurantId.equals(restaurantId))
            ..where((t) => t.sort.equals(sort)))
          .go();
      await _db.batch((b) {
        for (var i = 0; i < items.length; i++) {
          final raw = items[i];
          final id = (raw['id'] as num?)?.toInt();
          if (id == null) continue;
          b.insert(
            _db.reviewsTable,
            ReviewsTableCompanion.insert(
              id: id,
              restaurantId: restaurantId,
              sort: Value(sort),
              position: Value(i),
              json: jsonEncode(raw),
              cachedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }
}

DateTime _cutoff() =>
    DateTime.now().toUtc().subtract(CachePolicy.publicReadTtl);
