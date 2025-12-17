import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../../domains/repositories/image_repository.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final RestClient rest;
  ImageRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, String>> uploadImage(File file) async {
    return executeWithErrorHandling(() async {
      Logger().e(file);
      final res = await rest.uploadImage(
        file
      );
      json.decode(res);
      return json.decode(res)['picture'];
    });
  }
}