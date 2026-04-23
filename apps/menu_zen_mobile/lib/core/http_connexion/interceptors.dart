import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:data/services/db_service.dart';

/// Key used by [RequestInterceptor] to show 403 dialogs.
/// Set this to your app's navigator key before using Dio.
GlobalKey<NavigatorState>? appNavigatorKey;

class LoggingInterceptors extends Interceptor {
  LoggingInterceptors();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log(
      'REQUEST[${options.method}] => PATH: ${options.path} '
      '\n Headers: ${options.headers} '
      '\n Query: ${options.queryParameters} '
      '\n Body: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      'RESPONSE[${response.statusCode}] => PATH: '
      '${response.requestOptions.path} \n res:: '
      '${json.encode(response.data)}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      'ERROR[${err.response?.statusCode ?? 'Unknown'}] => '
      'PATH: ${err.requestOptions.path}',
    );
    super.onError(err, handler);
  }
}

class RequestInterceptor extends Interceptor {
  final DbService db;
  final Dio dio;

  RequestInterceptor({required this.db, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await db.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403) {
      final context = appNavigatorKey?.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Accès Refusé'),
            content: const Text(
              'Vous n\'avez pas la permission d\'effectuer cette action.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    return handler.next(err);
  }
}
