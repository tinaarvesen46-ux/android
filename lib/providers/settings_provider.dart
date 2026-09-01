import 'package:flutter/foundation.dart';

import '../services/settings_service.dart';

/// Exposes persisted preferences to the UI. Every setter writes through to
/// storage immediately so no change is lost if the app is killed.
class SettingsProvider extends ChangeNotifier {
  static const String ghostModeKey = 'map.ghost_mode';
  static const String avatarPrefix = 'avatar.';

  final SettingsService _service;

  SettingsProvider({required SettingsService service}) : _service = service;

  bool boolFor(String key, {bool fallback = false}) =>
      _service.getBool(key, fallback: fallback);

  Future<void> setBool(String key, bool value) async {
    await _service.setBool(key, value);
    notifyListeners();
  }

  String stringFor(String key, {required String fallback}) =>
      _service.getString(key, fallback: fallback);

  Future<void> setString(String key, String value) async {
    await _service.setString(key, value);
    notifyListeners();
  }

  Map<String, String> get avatarConfig => _service.getMap(avatarPrefix);

  String get language => _service.getString('app.language', fallback: 'en');

  Future<void> setLanguage(String code) async {
    await _service.setString('app.language', code);
    notifyListeners();
  }

  Future<void> setAvatarPart(String part, String value) =>
      setString('$avatarPrefix$part', value);

  Future<void> resetAvatar() async {
    await _service.clearWithPrefix(avatarPrefix);
    notifyListeners();
  }
}
