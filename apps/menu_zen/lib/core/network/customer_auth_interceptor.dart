import 'package:data/services/customer_token_storage.dart';
import 'package:dio/dio.dart';

/// Attaches the persisted customer JWT to every outgoing request and exposes
/// 401 responses so the AuthBloc can drop the user back to the auth shell.
class CustomerAuthInterceptor extends Interceptor {
  final CustomerTokenStorage _tokenStorage;
  final Future<void> Function() _onUnauthorized;

  CustomerAuthInterceptor({
    required CustomerTokenStorage tokenStorage,
    required Future<void> Function() onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _onUnauthorized();
    }
    handler.next(err);
  }
}
