import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/settings_service.dart';
import '../models/app_settings.dart';
import '../core/dictionary_registry.dart';
import '../core/database_helper.dart';

/// Provides and persists [AppSettings] globally.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final loaded = await SettingsService.load();
    // If dictOrder is empty, initialize with default registry order
    List<String> newDictOrder;
    List<String> newActiveCodes;

    if (loaded.dictOrder.isEmpty) {
      newDictOrder = DictionaryRegistry.all.map((d) => d.codeLo).toList();
    } else {
      newDictOrder = loaded.dictOrder;
    }

    // Auto-enable any downloaded dictionaries that aren't already active
    final downloadedDicts = <String>{};
    for (final code in newDictOrder) {
      if (await DatabaseHelper.isAvailable(code)) {
        downloadedDicts.add(code);
      }
    }
    newActiveCodes = loaded.activeDictCodes.toList();
    for (final code in downloadedDicts) {
      if (!newActiveCodes.contains(code)) {
        newActiveCodes.add(code);
      }
    }
    // Sort active codes based on dictOrder
    newActiveCodes.sort((a, b) {
      final idxA = newDictOrder.indexOf(a);
      final idxB = newDictOrder.indexOf(b);
      return idxA.compareTo(idxB);
    });

    state = loaded.copyWith(
      dictOrder: newDictOrder,
      activeDictCodes: newActiveCodes,
    );
  }

  Future<void> update(AppSettings newSettings) async {
    state = newSettings;
    await SettingsService.save(newSettings);
  }

  Future<void> addActiveDict(String code) async {
    if (!state.activeDictCodes.contains(code)) {
      final newList = [...state.activeDictCodes, code];
      // Sort new active list based on master dictOrder
      newList.sort((a, b) {
        final idxA = state.dictOrder.indexOf(a);
        final idxB = state.dictOrder.indexOf(b);
        return idxA.compareTo(idxB);
      });
      await update(state.copyWith(activeDictCodes: newList));
    }
  }

  Future<void> removeActiveDict(String code) async {
    await update(
      state.copyWith(
        activeDictCodes: state.activeDictCodes.where((c) => c != code).toList(),
      ),
    );
  }

  Future<void> reorderDicts(List<String> newOrder) async {
    final activeCodes = List<String>.from(state.activeDictCodes);
    // Re-sort active codes whenever the master order changes
    activeCodes.sort((a, b) {
      final idxA = newOrder.indexOf(a);
      final idxB = newOrder.indexOf(b);
      return idxA.compareTo(idxB);
    });
    await update(
        state.copyWith(dictOrder: newOrder, activeDictCodes: activeCodes));
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
