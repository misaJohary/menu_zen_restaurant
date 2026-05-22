import 'package:drift/drift.dart';

class CustomerOrderItemsTable extends Table {
  @override
  String get tableName => 'customer_order_items_cache';

  IntColumn get id => integer()();
  IntColumn get orderId => integer()();
  IntColumn get menuItemId => integer()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get json => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
