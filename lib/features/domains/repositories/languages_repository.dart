import '../../../core/errors/failure.dart';
import '../../../core/http_connexion/multi_result.dart';
import '../entities/language_entity.dart';

abstract class LanguagesRepository {
  Future<MultiResult<Failure, List<LanguageEntity>>> getLanguages();
}
