import 'package:injectable/injectable.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/entities/language_entity.dart';
import 'package:domain/repositories/languages_repository.dart';

import 'package:data/errors/handle_exception.dart';
import 'package:data/http/rest_client.dart';

@LazySingleton(as: LanguagesRepository)
class LanguagesRepositoryImpl implements LanguagesRepository {
  final RestClient rest;

  LanguagesRepositoryImpl({required this.rest});

  @override
  Future<MultiResult<Failure, List<LanguageEntity>>> getLanguages() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getLanguages();
      return res;
    });
  }
}
