import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../services/db_service.dart';

class LoggingInterceptors extends Interceptor {

  LoggingInterceptors();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log(
        'REQUEST[${options.method}] => PATH: ${options.path} \n Extras: ${options.extra} \n Headers: ${options.headers} \n Query: ${options.queryParameters} \n Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path} \n res:: ${json.encode(response.data)}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
        'ERROR[${err.response?.statusCode ?? 'Unknown Status Code'}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}

class RequestInterceptor extends Interceptor {
  final DbService db;
  final Dio dio;

  RequestInterceptor({
    required this.db,
    @Named("noInterceptor") required this.dio,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await db.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    return handler.next(err);
  }
}