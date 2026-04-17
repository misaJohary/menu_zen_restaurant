// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:data/di/data_package_module.module.dart' as _i913;
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
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/presentations/managers/auths/auth_bloc.dart' as _i788;
import '../../features/presentations/managers/categories/categories_bloc.dart'
    as _i562;
import '../../features/presentations/managers/kitchens/kitchens_bloc.dart'
    as _i345;
import '../../features/presentations/managers/languages/languages_bloc.dart'
    as _i288;
import '../../features/presentations/managers/menu_item/menu_item_bloc.dart'
    as _i910;
import '../../features/presentations/managers/menus/menus_bloc.dart' as _i789;
import '../../features/presentations/managers/orders/order_menu_item/order_menu_item_bloc.dart'
    as _i528;
import '../../features/presentations/managers/orders/orders_bloc.dart' as _i414;
import '../../features/presentations/managers/restaurant/restaurant_bloc.dart'
    as _i864;
import '../../features/presentations/managers/stats/stats_bloc.dart' as _i406;
import '../../features/presentations/managers/tables/table_bloc.dart' as _i419;
import '../../features/presentations/managers/users/users_bloc.dart' as _i121;
import '../navigation/guards/auth_guards.dart' as _i1010;
import '../services/photon_geocoding_service.dart' as _i98;
import '../services/ws_service.dart' as _i950;
import 'injection_module.dart' as _i212;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i913.DataPackageModule().init(gh);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i460.SharedPreferencesAsync>(() => registerModule.prefs);
    gh.factory<_i562.CategoriesBloc>(
      () => _i562.CategoriesBloc(
        categoriesRepository: gh<_i485.CategoriesRepository>(),
      ),
    );
    gh.factory<_i406.StatsBloc>(
      () => _i406.StatsBloc(statsRepository: gh<_i424.StatsRepository>()),
    );
    gh.factory<String>(() => registerModule.baseUrl, instanceName: 'BaseUrl');
    gh.lazySingleton<_i1010.AuthGuard>(
      () => _i1010.AuthGuard(dbService: gh<_i1071.DbService>()),
    );
    gh.factory<_i528.OrderMenuItemBloc>(
      () => _i528.OrderMenuItemBloc(repo: gh<_i218.OrdersRepository>()),
    );
    gh.factory<_i414.OrdersBloc>(
      () => _i414.OrdersBloc(repo: gh<_i218.OrdersRepository>()),
    );
    gh.factory<_i98.PhotonGeometry>(
      () => _i98.PhotonGeometry(
        type: gh<String>(),
        coordinates: gh<List<double>>(),
      ),
    );
    gh.factory<_i98.PhotonResponse>(
      () => _i98.PhotonResponse(
        type: gh<String>(),
        features: gh<List<_i98.PhotonFeature>>(),
      ),
    );
    gh.factory<_i864.RestaurantBloc>(
      () => _i864.RestaurantBloc(restaurant: gh<_i639.RestaurantRepository>()),
    );
    gh.factory<_i789.MenusBloc>(
      () => _i789.MenusBloc(menusRepository: gh<_i44.MenusRepository>()),
    );
    gh.factory<_i288.LanguagesBloc>(
      () => _i288.LanguagesBloc(
        languagesRepository: gh<_i40.LanguagesRepository>(),
      ),
    );
    gh.factory<_i345.KitchensBloc>(
      () => _i345.KitchensBloc(gh<_i242.KitchenRepository>()),
    );
    gh.factory<_i98.PhotonException>(
      () => _i98.PhotonException(gh<String>(), gh<int>()),
    );
    gh.factory<_i98.PhotonProperties>(
      () => _i98.PhotonProperties(
        city: gh<String>(),
        country: gh<String>(),
        name: gh<String>(),
        postcode: gh<String>(),
        state: gh<String>(),
        district: gh<String>(),
        street: gh<String>(),
        housenumber: gh<String>(),
      ),
    );
    gh.factory<_i788.AuthBloc>(
      () => _i788.AuthBloc(gh<_i427.AuthRepository>()),
    );
    gh.factory<_i121.UsersBloc>(
      () => _i121.UsersBloc(gh<_i427.AuthRepository>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<String>(instanceName: 'BaseUrl'),
        gh<_i1071.DbService>(),
      ),
      instanceName: 'withInterceptor',
    );
    gh.lazySingleton<_i361.Dio>(
      () =>
          registerModule.dioNoInterceptor(gh<String>(instanceName: 'BaseUrl')),
      instanceName: 'noInterceptor',
    );
    gh.factory<_i419.TableBloc>(
      () => _i419.TableBloc(tablesRepository: gh<_i347.TablesRepository>()),
    );
    gh.lazySingleton<_i950.RestaurantWebSocketService>(
      () => _i950.RestaurantWebSocketService(
        dbService: gh<_i1071.DbService>(),
        baseUrl: gh<String>(instanceName: 'BaseUrl'),
      ),
    );
    gh.factory<_i910.MenuItemBloc>(
      () => _i910.MenuItemBloc(
        repo: gh<_i981.MenuItemRepository>(),
        imageRepo: gh<_i500.ImageRepository>(),
      ),
    );
    gh.factory<_i98.PhotonFeature>(
      () => _i98.PhotonFeature(
        type: gh<String>(),
        geometry: gh<_i98.PhotonGeometry>(),
        properties: gh<_i98.PhotonProperties>(),
      ),
    );
    gh.lazySingleton<_i98.PhotonGeocodingService>(
      () => _i98.PhotonGeocodingService(
        gh<_i361.Dio>(instanceName: 'noInterceptor'),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i212.RegisterModule {}
