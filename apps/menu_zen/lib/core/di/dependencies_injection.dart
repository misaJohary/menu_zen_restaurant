import 'package:data/config/base_url_config.dart';
import 'package:data/datasources/customer_favorites_remote_datasource.dart';
import 'package:data/datasources/customer_reviews_remote_datasource.dart';
import 'package:data/datasources/customers_remote_datasource.dart';
import 'package:data/datasources/public_restaurants_remote_datasource.dart';
import 'package:data/repositories/customer_auth_repository_impl.dart';
import 'package:data/repositories/customer_reviews_repository_impl.dart';
import 'package:data/repositories/favorites_repository_impl.dart';
import 'package:data/repositories/geolocation_repository_impl.dart';
import 'package:data/repositories/public_restaurants_repository_impl.dart';
import 'package:data/services/customer_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:domain/repositories/customer_auth_repository.dart';
import 'package:domain/repositories/customer_reviews_repository.dart';
import 'package:domain/repositories/favorites_repository.dart';
import 'package:domain/repositories/geolocation_repository.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/customer_review/customer_review_cubit.dart';
import '../../presentation/bloc/discover/discover_cubit.dart';
import '../../presentation/bloc/favorites/favorites_cubit.dart';
import '../../presentation/bloc/locale/locale_cubit.dart';
import '../../presentation/bloc/restaurant_detail/restaurant_detail_cubit.dart';
import '../../presentation/bloc/search/search_bloc.dart';
import '../network/customer_auth_interceptor.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ---- Storage ----------------------------------------------------------
  getIt.registerLazySingleton<SharedPreferencesAsync>(
    () => SharedPreferencesAsync(),
  );
  getIt.registerLazySingleton<CustomerTokenStorage>(
    () => CustomerTokenStorageImpl(getIt<SharedPreferencesAsync>()),
  );

  // ---- Dio --------------------------------------------------------------
  // Unauthenticated Dio used for `/public/*` endpoints. Reads
  // BaseUrlConfig.current lazily so a runtime URL switch takes effect on
  // the next call.
  getIt.registerLazySingleton<Dio>(() {
    return Dio(
      BaseOptions(
        baseUrl: BaseUrlConfig.current,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }, instanceName: 'publicDio');

  // Customer-scoped Dio. Attaches the JWT and surfaces 401s to AuthBloc.
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaseUrlConfig.current,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    dio.interceptors.add(
      CustomerAuthInterceptor(
        tokenStorage: getIt<CustomerTokenStorage>(),
        onUnauthorized: () async {
          if (getIt.isRegistered<AuthBloc>()) {
            getIt<AuthBloc>().add(AuthTokenExpired());
          }
        },
      ),
    );
    return dio;
  }, instanceName: 'customerDio');

  // ---- Datasources ------------------------------------------------------
  getIt.registerLazySingleton<PublicRestaurantsRemoteDatasource>(
    () => PublicRestaurantsRemoteDatasource(
      getIt<Dio>(instanceName: 'publicDio'),
    ),
  );

  getIt.registerLazySingleton<CustomersRemoteDatasource>(
    () => CustomersRemoteDatasource(getIt<Dio>(instanceName: 'customerDio')),
  );

  getIt.registerLazySingleton<CustomerReviewsRemoteDatasource>(
    () => CustomerReviewsRemoteDatasource(
      getIt<Dio>(instanceName: 'customerDio'),
    ),
  );

  getIt.registerLazySingleton<CustomerFavoritesRemoteDatasource>(
    () => CustomerFavoritesRemoteDatasource(
      getIt<Dio>(instanceName: 'customerDio'),
    ),
  );

  // ---- Repositories -----------------------------------------------------
  getIt.registerLazySingleton<PublicRestaurantsRepository>(
    () => PublicRestaurantsRepositoryImpl(
      getIt<PublicRestaurantsRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<GeolocationRepository>(
    () => GeolocationRepositoryImpl(),
  );

  getIt.registerLazySingleton<CustomerAuthRepository>(
    () => CustomerAuthRepositoryImpl(
      remote: getIt<CustomersRemoteDatasource>(),
      tokenStorage: getIt<CustomerTokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<CustomerReviewsRepository>(
    () => CustomerReviewsRepositoryImpl(
      getIt<CustomerReviewsRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt<CustomerFavoritesRemoteDatasource>()),
  );

  // ---- Blocs & cubits ---------------------------------------------------
  // AuthBloc is registered as a lazy singleton (one instance for the whole
  // app) — it is the source of truth for the current customer.
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      auth: getIt<CustomerAuthRepository>(),
      tokenStorage: getIt<CustomerTokenStorage>(),
    ),
  );

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

  getIt.registerFactory<CustomerReviewCubit>(
    () => CustomerReviewCubit(getIt<CustomerReviewsRepository>()),
  );

  // App-scoped: a single instance keeps the heart state in sync across
  // Discover, Search, Restaurant detail, and the Favorites page.
  getIt.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(getIt<FavoritesRepository>()),
  );

  // App-scoped: the chosen UI language. Default is `null` (= device locale).
  getIt.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(getIt<SharedPreferencesAsync>()),
  );
}
