import 'dart:convert';

import 'package:qdone/features/home_widget/data/widget_storage_contract.dart';
import 'package:qdone/features/settings/domain/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._preferences);

  static const _settingsKey = WidgetStorageContract.settingsKey;

  final SharedPreferences _preferences;

  Future<UserSettings> readSettings() async {
    await _preferences.reload();
    final raw = _preferences.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const UserSettings();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const UserSettings();
      }
      return UserSettings.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return const UserSettings();
    }
  }

  Future<void> writeSettings(UserSettings settings) {
    return _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
