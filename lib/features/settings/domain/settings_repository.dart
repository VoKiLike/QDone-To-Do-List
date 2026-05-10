import 'package:qdone/features/settings/domain/user_settings.dart';

abstract interface class SettingsRepository {
  Future<UserSettings> read();
  Future<void> save(UserSettings settings);
}
