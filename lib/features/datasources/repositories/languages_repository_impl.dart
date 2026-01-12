import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/features/domains/entities/language_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/languages_repository.dart';

import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/rest_client.dart';

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




