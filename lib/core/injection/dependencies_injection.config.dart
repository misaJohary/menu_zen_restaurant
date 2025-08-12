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

import '../../features/datasources/repositories/restaurant_respository_impl.dart'
    as _i659;
import '../../features/domains/repositories/restaurant_repository.dart'
    as _i986;
import '../../features/presentations/managers/restaurant/restaurant_bloc.dart'
    as _i864;
import '../http_connexion/rest_client.dart' as _i306;
import '../services/photon_geocoding_service.dart' as _i98;
import 'injection_module.dart' as _i212;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<String>(() => registerModule.baseUrl, instanceName: 'BaseUrl');
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
    gh.factory<_i98.PhotonException>(
      () => _i98.PhotonException(gh<String>(), gh<int>()),
    );
    gh.factory<_i98.PhotonResponse>(
      () => _i98.PhotonResponse(
        type: gh<String>(),
        features: gh<List<_i98.PhotonFeature>>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<String>(instanceName: 'BaseUrl')),
    );
    gh.lazySingleton<_i98.PhotonGeocodingService>(
      () => _i98.PhotonGeocodingService(gh<_i361.Dio>()),
    );
    gh.factory<_i306.RestClient>(
      () => _i306.RestClient(
        gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'BaseUrl'),
      ),
    );
    gh.lazySingleton<_i986.RestaurantRepository>(
      () => _i659.RestaurantRepositoryImpl(rest: gh<_i306.RestClient>()),
    );
    gh.factory<_i864.RestaurantBloc>(
      () => _i864.RestaurantBloc(restaurant: gh<_i986.RestaurantRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i212.RegisterModule {}
