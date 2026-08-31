import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for user preferences. Values survive restarts; syncing
/// them across devices requires a backend settings endpoint.
class SettingsService {
  final SharedPreferences _prefs;

  SettingsService._(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  bool getBool(String key, {bool fallback = false}) =>
      _prefs.getBool(key) ?? fallback;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  String getString(String key, {String fallback = ''}) =>
      _prefs.getString(key) ?? fallback;

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// Every stored string whose key starts with [prefix], keyed without it.
  Map<String, String> getMap(String prefix) {
    final result = <String, String>{};
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(prefix)) continue;
      final value = _prefs.getString(key);
      if (value != null) result[key.substring(prefix.length)] = value;
    }
    return result;
  }

  Future<void> clearWithPrefix(String prefix) async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(prefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
