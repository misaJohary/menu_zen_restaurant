import 'package:flutter/services.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:menu_zen_restaurant/core/errors/exceptions.dart';
import 'package:menu_zen_restaurant/core/extensions/object_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/screens/restaurant_registration_screen.dart';
import '../http_connexion/multi_result.dart';
import 'failure.dart';

Future<MultiResult<Failure, T>> executeWithErrorHandling<T>(
  Future<T> Function() action,
) async {
  try {
    final result = await action();
    return SuccessResult(result);
  } on PlatformException catch (e) {
    return FailureResult(ServerFailure(message: e.message));
  } on DioException catch (e) {
    e.toString().log();
    return FailureResult(handleDioException(e));
  } on ItemNotFoundException catch (e) {
    e.message.log();
    return FailureResult(UnexpectedFailure(message: e.message));
  } catch (e) {
    e.toString().log();
    return FailureResult(UnexpectedFailure(message: e.toString()));
  }
}

Failure handleDioException(DioException e) {
  if (e.response?.statusCode == 400) {
    return ServerFailure(message: e.response?.data['message']);
  }
  if (e.error.runtimeType == SocketException) {
    return InternetConnectionFailure();
  }
  return ServerFailure();
}
