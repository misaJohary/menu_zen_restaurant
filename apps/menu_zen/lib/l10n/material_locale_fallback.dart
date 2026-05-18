import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// `flutter_localizations` does not ship Material/Cupertino translations for
/// Malagasy (`mg`). Without a delegate Flutter logs a warning at startup and
/// framework widgets (date picker, time picker, scrollbar a11y labels) fall
/// back to English. We forward to the French translations instead — closest
/// to the Malagasy audience.
class _MaterialMgFallbackDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialMgFallbackDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_MaterialMgFallbackDelegate old) => false;
}

class _CupertinoMgFallbackDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoMgFallbackDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'mg';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));

  @override
  bool shouldReload(_CupertinoMgFallbackDelegate old) => false;
}

const localeFallbackDelegates = <LocalizationsDelegate<dynamic>>[
  _MaterialMgFallbackDelegate(),
  _CupertinoMgFallbackDelegate(),
];
