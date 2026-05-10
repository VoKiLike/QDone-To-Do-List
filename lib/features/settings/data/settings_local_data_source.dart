import 'dart:convert';

import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._preferences);

  static const _settingsKey = 'qdone.settings.v1';

  final SharedPreferences _preferences;

  Future<UserSettings> readSettings() async {
    final raw = _preferences.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const UserSettings();
    }
    return UserSettings.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> writeSettings(UserSettings settings) {
    return _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
