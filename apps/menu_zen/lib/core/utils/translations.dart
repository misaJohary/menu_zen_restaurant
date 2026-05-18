import 'package:domain/entities/translation_base.dart';
import 'package:flutter/widgets.dart';

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

/// Returns the language code currently used by the Material localizations —
/// i.e. the locale negotiated between the user's app locale and the device's.
String localeLanguageOf(BuildContext context) =>
    Localizations.localeOf(context).languageCode;
