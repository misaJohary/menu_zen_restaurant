
import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_restaurant_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/datasources/models/category_model.dart';
import '../../features/datasources/models/menu_item_model.dart';
import '../../features/datasources/models/menu_model.dart';
import '../../features/datasources/models/token.dart';

part 'rest_client.g.dart';

@injectable
@RestApi()
abstract class RestClient {
  @factoryMethod
  factory RestClient(
    @Named("withInterceptor") Dio dio, {
    @Named('BaseUrl') String baseUrl,
  }) = _RestClient;

  @POST('/login')
  Future<Token> login(@Part() String username, @Part() String password);

  @GET('/user')
  Future<UserRestaurantModel> getUser();

  @POST('/restaurants')
  Future<UserRestaurantModel> createRestaurant(
    @Body() UserRestaurantModel params,
  );

  @GET('/menus')
  Future<List<MenuModel>> getMenus();

  @POST('/menus')
  Future<MenuModel> createMenus(@Body() MenuModel params);

  @PATCH('/menus/{id}')
  Future<MenuModel> updateMenus(@Path() int id, @Body() MenuModel params);

  @DELETE('/menus/{id}')
  Future<MenuModel> deleteMenus(@Path() int id);

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
  Future<CategoryModel> deleteCategories(@Path() int id);

  @GET('/menu-items')
  Future<List<MenuItemModel>> getMenuItems();

  @GET('/categories/{categoryId}/menu-items')
  Future<List<MenuItemModel>> getMenuItemsByCategory(@Path() int categoryId);

  @POST('/menu-items-pics')
  Future<MenuItemModel> createMenuItems({
    @Part() required String name,
    @Part() String? description,
    @Part() required double price,
    //@Part() required bool isAvailable,
    @Part(name: 'category_id') required int categoryId,
    @Part(name: 'menu_ids') required String menus,
    @Part() required File? picture,
  });

  @PATCH('/menu-items/{id}')
  Future<MenuItemModel> updateMenuItems(
    @Path() int id,
    @Body() MenuItemModel params,
  );

  @DELETE('/menu-items/{id}')
  Future<MenuItemModel> deleteMenuItems(@Path() int id);
}
