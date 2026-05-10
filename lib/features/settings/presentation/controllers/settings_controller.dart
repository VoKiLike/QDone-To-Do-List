import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_do_list_app/app/app_providers.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/settings_repository.dart';
import 'package:flutter_to_do_list_app/features/settings/domain/user_settings.dart';
import 'package:flutter_to_do_list_app/features/tasks/domain/entities/task_enums.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<UserSettings>>((ref) {
      return SettingsController(ref.watch(settingsRepositoryProvider))..load();
    });

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings =
      ref.watch(settingsControllerProvider).valueOrNull ?? const UserSettings();
  return switch (settings.themeMode) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
  };
});

class SettingsController extends StateNotifier<AsyncValue<UserSettings>> {
  SettingsController(this._repository) : super(const AsyncValue.loading());

  final SettingsRepository _repository;

  Future<void> load() async {
    try {
      state = AsyncValue.data(await _repository.read());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> update(UserSettings settings) async {
    state = AsyncValue.data(settings);
    await _repository.save(settings);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = state.valueOrNull ?? const UserSettings();
    await update(current.copyWith(themeMode: mode));
  }

  Future<void> setLanguage(String languageCode) async {
    final current = state.valueOrNull ?? const UserSettings();
    await update(current.copyWith(languageCode: 'ru'));
  }
}
