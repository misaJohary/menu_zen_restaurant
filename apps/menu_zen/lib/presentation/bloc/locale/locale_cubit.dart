import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Holds the active app [Locale]. `null` means "follow the device locale".
class LocaleCubit extends Cubit<Locale?> {
  static const _storageKey = 'app.locale';

  final SharedPreferencesAsync _prefs;

  LocaleCubit(this._prefs) : super(null);

  /// Locales the app ships translations for.
  static const supported = AppLocalizations.supportedLocales;

  /// Loads the persisted locale (if any). Falls back to `null`, which means
  /// the app follows the device locale.
  Future<void> load() async {
    final stored = await _prefs.getString(_storageKey);
    if (stored == null || stored.isEmpty) return;
    final locale = Locale(stored);
    if (_isSupported(locale)) emit(locale);
  }

  /// Switches the active locale. Pass `null` to revert to the device locale.
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_storageKey);
      emit(null);
      return;
    }
    if (!_isSupported(locale)) return;
    await _prefs.setString(_storageKey, locale.languageCode);
    emit(locale);
  }

  /// Resolves the locale that should actually be applied right now: the
  /// user's choice if set, otherwise the device locale clamped to a
  /// supported one, otherwise English.
  Locale resolve() {
    final selected = state;
    if (selected != null) return selected;
    return _resolveDeviceLocale();
  }

  static Locale _resolveDeviceLocale() {
    final device = ui.PlatformDispatcher.instance.locale;
    for (final loc in supported) {
      if (loc.languageCode == device.languageCode) return loc;
    }
    return const Locale('en');
  }

  bool _isSupported(Locale locale) {
    for (final loc in supported) {
      if (loc.languageCode == locale.languageCode) return true;
    }
    return false;
  }
}
