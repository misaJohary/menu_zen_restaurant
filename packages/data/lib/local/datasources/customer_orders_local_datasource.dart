import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../cache_policy.dart';

class CustomerOrdersLocalDatasource {
  CustomerOrdersLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getOrders() async {
    final cutoff =
        DateTime.now().toUtc().subtract(CachePolicy.customerHistoryTtl);
    final query = _db.select(_db.customerOrdersTable)
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(cutoff))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    final rows = await query.get();
    return rows
        .map((r) => jsonDecode(r.json) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> getOrder(int id) async {
    final cutoff =
        DateTime.now().toUtc().subtract(CachePolicy.customerHistoryTtl);
    final query = _db.select(_db.customerOrdersTable)
      ..where((t) => t.id.equals(id))
      ..where((t) => t.cachedAt.isBiggerOrEqualValue(cutoff));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return jsonDecode(row.json) as Map<String, dynamic>;
  }

  Future<void> upsertOrder(Map<String, dynamic> raw) async {
    final id = (raw['id'] as num?)?.toInt();
    if (id == null) return;
    final restaurantId = (raw['restaurant_id'] as num?)?.toInt() ?? 0;
    final status = raw['order_status']?.toString();
    final updatedAt = _parseDate(raw['updated_at'] ?? raw['created_at']);
    await _db.into(_db.customerOrdersTable).insertOnConflictUpdate(
          CustomerOrdersTableCompanion.insert(
            id: Value(id),
            restaurantId: restaurantId,
            status: Value(status),
            json: jsonEncode(raw),
            updatedAt: Value(updatedAt),
            cachedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> replaceOrders(List<Map<String, dynamic>> rawList) async {
    await _db.transaction(() async {
      await _db.delete(_db.customerOrdersTable).go();
      for (final raw in rawList) {
        await upsertOrder(raw);
      }
    });
  }

  Future<void> clearAll() => _db.delete(_db.customerOrdersTable).go();
}

DateTime? _parseDate(Object? raw) {
  if (raw == null) return null;
  final s = raw.toString();
  return DateTime.tryParse(s)?.toUtc();
}
