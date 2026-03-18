import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/settings_service.dart';
import '../models/app_settings.dart';

/// Provides and persists [AppSettings] globally.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await SettingsService.load();
  }

  Future<void> update(AppSettings newSettings) async {
    state = newSettings;
    await SettingsService.save(newSettings);
  }

  Future<void> addActiveDict(String code) async {
    if (!state.activeDictCodes.contains(code)) {
      await update(
        state.copyWith(
          activeDictCodes: [...state.activeDictCodes, code],
        ),
      );
    }
  }

  Future<void> removeActiveDict(String code) async {
    await update(
      state.copyWith(
        activeDictCodes:
            state.activeDictCodes.where((c) => c != code).toList(),
      ),
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
