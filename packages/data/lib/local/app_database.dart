import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/customer_order_items_table.dart';
import 'tables/customer_orders_table.dart';
import 'tables/customer_reservations_table.dart';
import 'tables/favorites_table.dart';
import 'tables/menu_items_table.dart';
import 'tables/menus_table.dart';
import 'tables/meta_table.dart';
import 'tables/restaurant_details_table.dart';
import 'tables/restaurants_table.dart';
import 'tables/reviews_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    RestaurantsTable,
    RestaurantDetailsTable,
    MenusTable,
    MenuItemsTable,
    CustomerOrdersTable,
    CustomerOrderItemsTable,
    CustomerReservationsTable,
    FavoritesTable,
    ReviewsTable,
    MetaTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<void> clearAll() async {
    await batch((b) {
      b.deleteAll(restaurantsTable);
      b.deleteAll(restaurantDetailsTable);
      b.deleteAll(menusTable);
      b.deleteAll(menuItemsTable);
      b.deleteAll(customerOrdersTable);
      b.deleteAll(customerOrderItemsTable);
      b.deleteAll(customerReservationsTable);
      b.deleteAll(favoritesTable);
      b.deleteAll(reviewsTable);
      b.deleteAll(metaTable);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'menu_zen_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
