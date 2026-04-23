import 'dart:io';

import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class ImageRepository {
  Future<MultiResult<Failure, String>> uploadImage(File file);
}
