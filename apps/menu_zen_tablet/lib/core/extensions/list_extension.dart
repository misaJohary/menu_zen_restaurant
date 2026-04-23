// Base interface that all translation models should implement
import 'package:flutter/material.dart';

import 'package:domain/entities/translation_base.dart';

// Extension for any list of translatable items
extension TranslatableListExtension<T extends TranslationBase> on List<T> {
  /// Get translation for specific language with fallback
  T? getTranslation(String languageCode, {String fallbackCode = 'en'}) {
    if (isEmpty) return null;

    try {
      return firstWhere((t) => t.languageCode == languageCode);
    } catch (e) {
      try {
        return firstWhere((t) => t.languageCode == fallbackCode);
      } catch (e) {
        return first;
      }
    }
  }

  /// Get any field from translation with fallback
  String getField(
    String languageCode,
    String Function(T) fieldExtractor, {
    String fallbackCode = 'en',
    String defaultValue = '',
  }) {
    final translation = getTranslation(
      languageCode,
      fallbackCode: fallbackCode,
    );
    if (translation == null) return defaultValue;
    return fieldExtractor(translation);
  }

  /// Get optional field from translation with fallback
  String? getOptionalField(
    String languageCode,
    String? Function(T) fieldExtractor, {
    String fallbackCode = 'en',
  }) {
    final translation = getTranslation(
      languageCode,
      fallbackCode: fallbackCode,
    );
    if (translation == null) return null;
    return fieldExtractor(translation);
  }

  /// Context-aware: Get field using BuildContext locale
  String localizedField(
    BuildContext context,
    String Function(T) fieldExtractor, {
    String fallbackCode = 'en',
    String defaultValue = '',
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    return getField(
      locale,
      fieldExtractor,
      fallbackCode: fallbackCode,
      defaultValue: defaultValue,
    );
  }

  /// Context-aware: Get optional field using BuildContext locale
  String? localizedOptionalField(
    BuildContext context,
    String? Function(T) fieldExtractor, {
    String fallbackCode = 'en',
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    return getOptionalField(locale, fieldExtractor, fallbackCode: fallbackCode);
  }
}
