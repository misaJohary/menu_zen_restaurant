import 'package:data/config/base_url_config.dart';
import 'package:data/di/data_package_module.module.dart';
import 'package:data/services/db_service.dart';
import 'package:dio/dio.dart';
import 'package:domain/repositories/auth_repository.dart';
import 'package:domain/repositories/menu_item_repository.dart';
import 'package:domain/repositories/orders_repository.dart';
import 'package:domain/repositories/tables_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../http_connexion/interceptors.dart';
import '../services/ws_service.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/notifications/notification_cubit.dart';
import '../../presentation/bloc/orders/orders_bloc.dart';
import '../../presentation/bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import '../../presentation/bloc/tables/table_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final gh = GetItHelper(getIt, null, null);

  // SharedPreferences — needed by DbService (registered in DataPackageModule)
  gh.lazySingleton<SharedPreferencesAsync>(() => SharedPreferencesAsync());

  // Base URL string — needed by RestClient (registered in DataPackageModule)
  gh.factory<String>(
    () => BaseUrlConfig.current,
    instanceName: 'BaseUrl',
  );

  // Dio without interceptor — used as the "refresh" Dio inside RequestInterceptor
  gh.lazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: BaseUrlConfig.current)),
    instanceName: 'noInterceptor',
  );

  // Dio with auth + logging interceptors — used by RestClient
  gh.lazySingleton<Dio>(
    () {
      final dio = Dio(BaseOptions(baseUrl: BaseUrlConfig.current));
      dio.interceptors
        ..add(LoggingInterceptors())
        ..add(RequestInterceptor(
          dio: getIt<Dio>(instanceName: 'noInterceptor'),
          db: getIt<DbService>(),
        ));
      return dio;
    },
    instanceName: 'withInterceptor',
  );

  // Data package: registers DbService, RestClient, all repositories
  await DataPackageModule().init(gh);

  // WebSocket service — singleton so the connection is shared
  gh.lazySingleton<RestaurantWebSocketService>(
    () => RestaurantWebSocketService(
      dbService: getIt<DbService>(),
      baseUrl: getIt<String>(instanceName: 'BaseUrl'),
    ),
  );

  // App-level BLoC factories (new instance per BlocProvider)
  gh.factory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  gh.factory<OrdersBloc>(
    () => OrdersBloc(repo: getIt<OrdersRepository>()),
  );
  gh.factory<OrderMenuItemBloc>(
    () => OrderMenuItemBloc(
      repo: getIt<OrdersRepository>(),
      menuItemRepo: getIt<MenuItemRepository>(),
    ),
  );
  gh.factory<TableBloc>(
    () => TableBloc(tablesRepository: getIt<TablesRepository>()),
  );
  gh.factory<NotificationCubit>(
    () => NotificationCubit(prefs: getIt<SharedPreferencesAsync>()),
  );
}
