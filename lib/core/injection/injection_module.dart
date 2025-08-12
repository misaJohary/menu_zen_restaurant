import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

@module
abstract class RegisterModule {
  @Named("BaseUrl")
  String get baseUrl => dotenv.env['BASE_URL']!;

  @preResolve
  Future<SharedPreferences> get prefs async => SharedPreferences.getInstance();

  @lazySingleton
  Dio dio(@Named('BaseUrl') String url) {
    final dio = Dio(BaseOptions(baseUrl: url));
    return dio;
  }
}