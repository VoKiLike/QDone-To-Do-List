import 'dart:convert';

import 'package:qdone/features/home_widget/data/widget_storage_contract.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._preferences);

  static const _settingsKey = WidgetStorageContract.settingsKey;

  final SharedPreferences _preferences;
  UserSettings? _cache;

  Future<UserSettings> readSettings() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }
    final raw = _preferences.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return _cache = const UserSettings();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return _cache = const UserSettings();
      }
      return _cache = UserSettings.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return _cache = const UserSettings();
    }
  }

  Future<void> writeSettings(UserSettings settings) {
    _cache = settings;
    return _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> reloadExternal() async {
    _cache = null;
    await _preferences.reload();
  }
}
