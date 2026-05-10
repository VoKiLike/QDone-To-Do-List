import 'package:flutter_to_do_list_app/features/settings/domain/user_settings.dart';

abstract interface class SettingsRepository {
  Future<UserSettings> read();
  Future<void> save(UserSettings settings);
}
