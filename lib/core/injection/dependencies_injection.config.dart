// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/datasources/repositories/auth_repository_impl.dart'
    as _i345;
import '../../features/datasources/repositories/categories_repository_impl.dart'
    as _i95;
import '../../features/datasources/repositories/menu_item_repository_impl.dart'
    as _i402;
import '../../features/datasources/repositories/menus_repository_impl.dart'
    as _i1052;
import '../../features/datasources/repositories/orders_repository_impl.dart'
    as _i745;
import '../../features/datasources/repositories/restaurant_respository_impl.dart'
    as _i659;
import '../../features/domains/repositories/auth_repository.dart' as _i643;
import '../../features/domains/repositories/categories_repository.dart'
    as _i518;
import '../../features/domains/repositories/menu_item_repository.dart' as _i442;
import '../../features/domains/repositories/menus_repository.dart' as _i1037;
import '../../features/domains/repositories/orders_repository.dart' as _i504;
import '../../features/domains/repositories/restaurant_repository.dart'
    as _i986;
import '../../features/presentations/managers/auths/auth_bloc.dart' as _i788;
import '../../features/presentations/managers/categories/categories_bloc.dart'
    as _i562;
import '../../features/presentations/managers/menu_item/menu_item_bloc.dart'
    as _i910;
import '../../features/presentations/managers/menus/menus_bloc.dart' as _i789;
import '../../features/presentations/managers/orders/order_menu_item/order_menu_item_bloc.dart'
    as _i528;
import '../../features/presentations/managers/orders/orders_bloc.dart' as _i414;
import '../../features/presentations/managers/restaurant/restaurant_bloc.dart'
    as _i864;
import '../http_connexion/rest_client.dart' as _i306;
import '../navigation/guards/auth_guards.dart' as _i1010;
import '../services/db_service.dart' as _i420;
import '../services/photon_geocoding_service.dart' as _i98;
import 'injection_module.dart' as _i212;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i460.SharedPreferencesAsync>(() => registerModule.prefs);
    gh.factory<String>(() => registerModule.baseUrl, instanceName: 'BaseUrl');
    gh.singleton<_i420.DbService>(
      () => _i420.DbServiceImp(prefs: gh<_i460.SharedPreferencesAsync>()),
    );
    gh.factory<_i98.PhotonGeometry>(
      () => _i98.PhotonGeometry(
        type: gh<String>(),
        coordinates: gh<List<double>>(),
      ),
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
    gh.factory<_i98.PhotonFeature>(
      () => _i98.PhotonFeature(
        type: gh<String>(),
        geometry: gh<_i98.PhotonGeometry>(),
        properties: gh<_i98.PhotonProperties>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () =>
          registerModule.dioNoInterceptor(gh<String>(instanceName: 'BaseUrl')),
      instanceName: 'noInterceptor',
    );
    gh.factory<_i98.PhotonException>(
      () => _i98.PhotonException(gh<String>(), gh<int>()),
    );
    gh.lazySingleton<_i1010.AuthGuard>(
      () => _i1010.AuthGuard(dbService: gh<_i420.DbService>()),
    );
    gh.lazySingleton<_i98.PhotonGeocodingService>(
      () => _i98.PhotonGeocodingService(
        gh<_i361.Dio>(instanceName: 'noInterceptor'),
      ),
    );
    gh.factory<_i98.PhotonResponse>(
      () => _i98.PhotonResponse(
        type: gh<String>(),
        features: gh<List<_i98.PhotonFeature>>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<String>(instanceName: 'BaseUrl'),
        gh<_i420.DbService>(),
      ),
      instanceName: 'withInterceptor',
    );
    gh.factory<_i306.RestClient>(
      () => _i306.RestClient(
        gh<_i361.Dio>(instanceName: 'withInterceptor'),
        baseUrl: gh<String>(instanceName: 'BaseUrl'),
      ),
    );
    gh.lazySingleton<_i504.OrdersRepository>(
      () => _i745.OrdersRepositoryImpl(rest: gh<_i306.RestClient>()),
    );
    gh.lazySingleton<_i518.CategoriesRepository>(
      () => _i95.CategoriesRepositoryImpl(rest: gh<_i306.RestClient>()),
    );
    gh.lazySingleton<_i1037.MenusRepository>(
      () => _i1052.MenusRepositoryImpl(rest: gh<_i306.RestClient>()),
    );
    gh.lazySingleton<_i643.AuthRepository>(
      () => _i345.AuthRepositoryImpl(
        db: gh<_i420.DbService>(),
        rest: gh<_i306.RestClient>(),
      ),
    );
    gh.factory<_i562.CategoriesBloc>(
      () => _i562.CategoriesBloc(
        categoriesRepository: gh<_i518.CategoriesRepository>(),
      ),
    );
    gh.lazySingleton<_i986.RestaurantRepository>(
      () => _i659.RestaurantRepositoryImpl(
        rest: gh<_i306.RestClient>(),
        db: gh<_i420.DbService>(),
      ),
    );
    gh.factory<_i788.AuthBloc>(
      () => _i788.AuthBloc(gh<_i643.AuthRepository>()),
    );
    gh.lazySingleton<_i442.MenuItemRepository>(
      () => _i402.MenuItemRepositoryImpl(rest: gh<_i306.RestClient>()),
    );
    gh.factory<_i789.MenusBloc>(
      () => _i789.MenusBloc(menusRepository: gh<_i1037.MenusRepository>()),
    );
    gh.factory<_i414.OrdersBloc>(
      () => _i414.OrdersBloc(repo: gh<_i504.OrdersRepository>()),
    );
    gh.factory<_i528.OrderMenuItemBloc>(
      () => _i528.OrderMenuItemBloc(repo: gh<_i504.OrdersRepository>()),
    );
    gh.factory<_i864.RestaurantBloc>(
      () => _i864.RestaurantBloc(restaurant: gh<_i986.RestaurantRepository>()),
    );
    gh.factory<_i910.MenuItemBloc>(
      () => _i910.MenuItemBloc(repo: gh<_i442.MenuItemRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i212.RegisterModule {}
