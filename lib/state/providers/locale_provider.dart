import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('settingsRepositoryProvider must be overridden');
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _repo;

  LocaleNotifier(this._repo, Locale initial) : super(initial);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('es'),
    Locale('pt'),
    Locale('zh'),
  ];
  static const Locale fallbackLocale = Locale('en');

  static Locale resolveInitial(SettingsRepository repo) {
    final saved = repo.loadLocaleCode();
    if (saved != null && _isSupported(saved)) {
      return Locale(saved);
    }
    final system = PlatformDispatcher.instance.locale.languageCode;
    if (_isSupported(system)) {
      return Locale(system);
    }
    return fallbackLocale;
  }

  static bool _isSupported(String code) =>
      supportedLocales.any((l) => l.languageCode == code);

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) return;
    state = locale;
    await _repo.saveLocaleCode(locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return LocaleNotifier(repo, LocaleNotifier.resolveInitial(repo));
});
