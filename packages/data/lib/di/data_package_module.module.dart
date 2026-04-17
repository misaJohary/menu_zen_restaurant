//@GeneratedMicroModule;DataPackageModule;package:data/di/data_package_module.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:data/http/rest_client.dart' as _i533;
import 'package:data/repositories/auth_repository_impl.dart' as _i819;
import 'package:data/repositories/categories_repository_impl.dart' as _i453;
import 'package:data/repositories/image_repository_impl.dart' as _i489;
import 'package:data/repositories/kitchen_repository_impl.dart' as _i111;
import 'package:data/repositories/languages_repository_impl.dart' as _i486;
import 'package:data/repositories/menu_item_repository_impl.dart' as _i261;
import 'package:data/repositories/menus_repository_impl.dart' as _i237;
import 'package:data/repositories/orders_repository_impl.dart' as _i43;
import 'package:data/repositories/restaurant_respository_impl.dart' as _i7;
import 'package:data/repositories/stats_repository_impl.dart' as _i189;
import 'package:data/repositories/tables_repository_impl.dart' as _i519;
import 'package:data/services/db_service.dart' as _i1071;
import 'package:dio/dio.dart' as _i361;
import 'package:domain/repositories/auth_repository.dart' as _i427;
import 'package:domain/repositories/categories_repository.dart' as _i485;
import 'package:domain/repositories/image_repository.dart' as _i500;
import 'package:domain/repositories/kitchen_repository.dart' as _i242;
import 'package:domain/repositories/languages_repository.dart' as _i40;
import 'package:domain/repositories/menu_item_repository.dart' as _i981;
import 'package:domain/repositories/menus_repository.dart' as _i44;
import 'package:domain/repositories/orders_repository.dart' as _i218;
import 'package:domain/repositories/restaurant_repository.dart' as _i639;
import 'package:domain/repositories/stats_repository.dart' as _i424;
import 'package:domain/repositories/tables_repository.dart' as _i347;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

class DataPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i1071.DbService>(
        () => _i1071.DbServiceImp(prefs: gh<_i460.SharedPreferencesAsync>()));
    gh.factory<_i533.RestClient>(() => _i533.RestClient(
          gh<_i361.Dio>(instanceName: 'withInterceptor'),
          baseUrl: gh<String>(instanceName: 'BaseUrl'),
        ));
    gh.lazySingleton<_i347.TablesRepository>(
        () => _i519.TablesRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i485.CategoriesRepository>(
        () => _i453.CategoriesRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i44.MenusRepository>(
        () => _i237.MenusRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i218.OrdersRepository>(
        () => _i43.OrdersRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i500.ImageRepository>(
        () => _i489.ImageRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i40.LanguagesRepository>(
        () => _i486.LanguagesRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i427.AuthRepository>(() => _i819.AuthRepositoryImpl(
          db: gh<_i1071.DbService>(),
          rest: gh<_i533.RestClient>(),
        ));
    gh.lazySingleton<_i424.StatsRepository>(
        () => _i189.StatsRepositoryImpl(gh<_i533.RestClient>()));
    gh.lazySingleton<_i981.MenuItemRepository>(
        () => _i261.MenuItemRepositoryImpl(rest: gh<_i533.RestClient>()));
    gh.lazySingleton<_i639.RestaurantRepository>(
        () => _i7.RestaurantRepositoryImpl(
              rest: gh<_i533.RestClient>(),
              db: gh<_i1071.DbService>(),
            ));
    gh.lazySingleton<_i242.KitchenRepository>(
        () => _i111.KitchenRepositoryImpl(rest: gh<_i533.RestClient>()));
  }
}
