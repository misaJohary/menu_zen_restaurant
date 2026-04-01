import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../../domains/repositories/image_repository.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final RestClient rest;
  ImageRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, String>> uploadImage(XFile file) async {
    return executeWithErrorHandling(() async {
      final bytes = await file.readAsBytes();

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: file.name,
        contentType: MediaType('image', 'jpeg'),
      );

      // Create FormData
      final formData = FormData.fromMap({
        'picture': multipartFile,
        // Add other fields if needed
        // 'title': 'My Image',
      });

      final res = await rest.uploadImage(formData);
      final decoded = json.decode(res);
      return decoded['picture'];
    });
  }
}
