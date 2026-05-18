import 'package:data/config/base_url_config.dart';
import 'package:data/datasources/public_restaurants_remote_datasource.dart';
import 'package:data/repositories/geolocation_repository_impl.dart';
import 'package:data/repositories/public_restaurants_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:domain/repositories/geolocation_repository.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:get_it/get_it.dart';

import '../../presentation/bloc/discover/discover_cubit.dart';
import '../../presentation/bloc/restaurant_detail/restaurant_detail_cubit.dart';
import '../../presentation/bloc/search/search_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Unauthenticated Dio used for `/public/*` endpoints. Reads
  // BaseUrlConfig.current lazily so a runtime URL switch takes effect on
  // the next call.
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaseUrlConfig.current,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return dio;
  }, instanceName: 'publicDio');

  getIt.registerLazySingleton<PublicRestaurantsRemoteDatasource>(
    () => PublicRestaurantsRemoteDatasource(getIt<Dio>(instanceName: 'publicDio')),
  );

  getIt.registerLazySingleton<PublicRestaurantsRepository>(
    () => PublicRestaurantsRepositoryImpl(
      getIt<PublicRestaurantsRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<GeolocationRepository>(
    () => GeolocationRepositoryImpl(),
  );

  // BLoC/Cubit factories — new instance per provider.
  getIt.registerFactory<DiscoverCubit>(
    () => DiscoverCubit(
      restaurants: getIt<PublicRestaurantsRepository>(),
      geo: getIt<GeolocationRepository>(),
    ),
  );

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(
      restaurants: getIt<PublicRestaurantsRepository>(),
      geo: getIt<GeolocationRepository>(),
    ),
  );

  getIt.registerFactory<RestaurantDetailCubit>(
    () => RestaurantDetailCubit(getIt<PublicRestaurantsRepository>()),
  );
}
