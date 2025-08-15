import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/features/datasources/models/user_restaurant_model.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/datasources/models/menu_model.dart';
import '../../features/datasources/models/token.dart';

part 'rest_client.g.dart';

@injectable
@RestApi()
abstract class RestClient {
  @factoryMethod
  factory RestClient(
      @Named("withInterceptor")
        Dio dio, {
        @Named('BaseUrl') String baseUrl,
      }) = _RestClient;

  @POST('/login')
  Future<Token> login(@Part() String username, @Part() String password);

  @GET('/user')
  Future<UserRestaurantModel> getUser();

  @POST('/restaurants')
  Future<UserRestaurantModel> createRestaurant(@Body() UserRestaurantModel params);

  @GET('/menus')
  Future<List<MenuModel>> getMenus();

  @POST('/menus')
  Future<MenuModel> createMenus(@Body() MenuModel params);

  @PATCH('/menus/{id}')
  Future<MenuModel> updateMenus(@Path() int id, @Body() MenuModel params);

  @DELETE('/menus/{id}')
  Future<MenuModel> deleteMenus(@Path() int id);
}