import 'package:domain/entities/translation_base.dart';

/// Picks the translation matching [languageCode]; falls back to the first
/// translation in the list, or `null` if the list is empty.
T? pickTranslation<T extends TranslationBase>(
  List<T> translations,
  String? languageCode,
) {
  if (translations.isEmpty) return null;
  if (languageCode != null) {
    for (final t in translations) {
      if (t.languageCode == languageCode) return t;
    }
  }
  return translations.first;
}
