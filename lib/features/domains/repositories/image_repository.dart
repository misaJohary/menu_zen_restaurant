import 'dart:io';

import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';

abstract class ImageRepository {
  Future<MultiResult<Failure, String>> uploadImage(File file);
}