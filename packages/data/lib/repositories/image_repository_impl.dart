import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

import 'package:domain/errors/failure.dart';
import 'package:data/errors/handle_exception.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:data/http/rest_client.dart';
import 'package:domain/repositories/image_repository.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final RestClient rest;
  ImageRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, String>> uploadImage(File file) async {
    return executeWithErrorHandling(() async {
      final bytes = await file.readAsBytes();

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: file.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );

      final formData = FormData.fromMap({'picture': multipartFile});

      final res = await rest.uploadImage(formData);
      final decoded = json.decode(res);
      return decoded['picture'];
    });
  }
}
