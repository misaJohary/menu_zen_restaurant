import '../entities/language_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class LanguagesRepository {
  Future<MultiResult<Failure, List<LanguageEntity>>> getLanguages();
}
