import 'package:flutter_to_do_list_app/features/settings/data/settings_local_data_source.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/settings_repository.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/user_settings.dart';

class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<UserSettings> read() => _dataSource.readSettings();

  @override
  Future<void> save(UserSettings settings) =>
      _dataSource.writeSettings(settings);
}
