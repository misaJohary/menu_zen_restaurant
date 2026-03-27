import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/features/datasources/models/order_count_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_restaurant_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/datasources/models/category_model.dart';
import '../../features/datasources/models/language_model.dart';
import '../../features/datasources/models/menu_item_model.dart';
import '../../features/datasources/models/menu_item_update_model.dart';
import '../../features/datasources/models/menu_model.dart';
import '../../features/datasources/models/order_menu_item_model.dart';
import '../../features/datasources/models/order_model.dart';
import '../../features/datasources/models/restaurant_model.dart';
import '../../features/datasources/models/revenues_model.dart';
import '../../features/datasources/models/role_model.dart';
import '../../features/datasources/models/table_model.dart';
import '../../features/datasources/models/token.dart';
import '../../features/datasources/models/top_menu_item_model.dart';
import '../../features/datasources/models/user_model.dart';

part 'rest_client.g.dart';

@injectable
@RestApi()
abstract class RestClient {
  @factoryMethod
  factory RestClient(
    @Named("withInterceptor") Dio dio, {
    @Named('BaseUrl') String baseUrl,
  }) = _RestClient;

  @POST('/images')
  Future<String> uploadImage(@Body() FormData formData);

  @POST('/login')
  Future<Token> login(@Part() String username, @Part() String password);

  @GET('/user')
  Future<UserRestaurantModel> getUser();

  @PATCH('/user')
  Future<UserModel> updateUser(@Body() UserModel params);

  @POST('/users')
  Future<UserModel> createUser(@Body() UserModel params);

  @GET('/users/')
  Future<List<UserModel>> getUsers();

  @PATCH('/users/{user_id}')
  Future<UserModel> updateAnyUser(
    @Path('user_id') int userId,
    @Body() UserModel params,
  );

  @DELETE('/users/{user_id}')
  Future<int> deleteUser(@Path('user_id') int userId);

  @GET('/admin/roles')
  Future<List<RoleModel>> getRoles();

  @GET('/admin/permissions')
  Future<List<String>> getPermissions();

  @POST('/restaurants')
  Future<UserRestaurantModel> createRestaurant(
    @Body() UserRestaurantModel params,
  );

  @PATCH('/restaurant')
  Future<RestaurantModel> updateRestaurant(@Body() RestaurantModel params);

  @GET('/menus')
  Future<List<MenuModel>> getMenus();

  @POST('/menus')
  Future<MenuModel> createMenus(@Body() MenuModel params);

  @PATCH('/menus/{id}')
  Future<MenuModel> updateMenus(@Path() int id, @Body() MenuModel params);

  @DELETE('/menus/{id}')
  Future<int> deleteMenus(@Path() int id);

  @GET('/categories')
  Future<List<CategoryModel>> getCategories();

  @POST('/categories')
  Future<CategoryModel> createCategories(@Body() CategoryModel params);

  @PATCH('/categories/{id}')
  Future<CategoryModel> updateCategories(
    @Path() int id,
    @Body() CategoryModel params,
  );

  @DELETE('/categories/{id}')
  Future<int> deleteCategories(@Path() int id);

  @GET('/menu-items')
  Future<List<MenuItemModel>> getMenuItems();

  @GET('/categories/{categoryId}/menu-items')
  Future<List<MenuItemModel>> getMenuItemsByCategory(@Path() int categoryId);

  @POST('/menu-items')
  Future<MenuItemModel> createMenuItems(@Body() MenuItemModel params);

  @GET('/menu-items-order')
  Future<List<OrderMenuItemModel>> getMenuItemsOrder();

  //orders
  @POST('/orders')
  Future<OrderModel> createOrder(@Body() OrderModel order);

  @GET('/orders')
  Future<List<OrderModel>> getOrders(
    @Queries() Map<String, dynamic> queries,
    //     {
    //   @Query('today_only') bool? todayOnly,
    //   @Query('skip') int? page,
    //   @Query('limit') int? limit,
    // }
  );

  @DELETE('/orders/{id}')
  Future<int> deleteOrder(@Path() int id);

  @PATCH('/orders/{id}')
  Future<OrderModel> updateOrder(@Path() int id, @Body() OrderModel order);

  @PATCH('/orders/{id}/status')
  Future<OrderModel> updateOrderStatus(
    @Path() int id,
    @Body() Map<String, String> orderStatus,
  );

  @PATCH('/orders/items/{id}/status')
  Future<OrderMenuItemModel> updateOrderMenuItemStatus(
    @Path() int id,
    @Body() Map<String, String> status,
  );

  @PATCH('/menu-items/{id}')
  Future<MenuItemModel> updateMenuItems(
    @Path() int id,
    @Body() MenuItemUpdateModel params,
  );

  @DELETE('/menu-items/{id}')
  Future<int> deleteMenuItems(@Path() int id);

  @POST('/tables')
  Future<TableModel> createTable(@Body() TableModel params);

  @GET('/tables')
  Future<List<TableModel>> getTables();

  @DELETE('/tables/{id}')
  Future<int> deleteTable(@Path() int id);

  @PATCH('/tables/{id}')
  Future<TableModel> updateTables(@Path() int id, @Body() TableModel params);

  @GET('/languages')
  Future<List<LanguageModel>> getLanguages();

  //stats
  @GET('/stats/revenue')
  Future<RevenuesModel> getRevenue({
    @Query('period') String? period,
    @Query('days') int? days,
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
  });

  @GET('/stats/top-menu-items')
  Future<List<TopMenuItemModel>> getTopMenuItems({
    @Query('period') String? period,
    @Query('days') int? days,
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
  });

  @GET('/stats/order-count')
  Future<OrderCountModel> getOrderCountToday({
    @Query('period') String? period,
    @Query('days') int? days,
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
  });
}
