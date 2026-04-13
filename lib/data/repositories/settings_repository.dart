import 'package:hive/hive.dart';

class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _localeKey = 'selected_locale';

  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  String? loadLocaleCode() => _box.get(_localeKey);

  Future<void> saveLocaleCode(String code) async {
    await _box.put(_localeKey, code);
  }
}
