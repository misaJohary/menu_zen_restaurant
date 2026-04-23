import 'package:injectable/injectable.dart';
import 'package:data/services/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../http_connexion/interceptors.dart';
import 'package:data/config/base_url_config.dart';

@module
abstract class RegisterModule {
  @Named("BaseUrl")
  String get baseUrl => BaseUrlConfig.current;

  //@preResolve
  @lazySingleton
  SharedPreferencesAsync get prefs => SharedPreferencesAsync();

  @Named("noInterceptor")
  @lazySingleton
  Dio dioNoInterceptor(@Named('BaseUrl') String url) {
    return Dio(BaseOptions(baseUrl: url));
  }

  @Named("withInterceptor")
  @lazySingleton
  Dio dio(@Named('BaseUrl') String url, DbService db) {
    final dio = Dio(BaseOptions(baseUrl: url));
    dio.interceptors
      ..add(LoggingInterceptors())
      ..add(RequestInterceptor(dio: dioNoInterceptor(url), db: db));
    return dio;
  }
}
