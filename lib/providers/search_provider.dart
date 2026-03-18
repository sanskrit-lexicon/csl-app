import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/search_service.dart';
import '../models/search_result.dart';
import 'settings_provider.dart';

/// Current headword search query text.
final headwordQueryProvider = StateProvider<String>((ref) => '');

/// Current definition search query text.
final definitionQueryProvider = StateProvider<String>((ref) => '');

/// User-closed tabs for the current search session.
final closedTabsProvider = StateProvider<Set<String>>((ref) => {});

/// Search results for a given dictionary code.
/// Runs whenever headwordQuery, definitionQuery, or settings change.
final searchResultsProvider = FutureProvider.family<List<SearchResult>, String>(
  (ref, dictCode) async {
    final settings = ref.watch(settingsProvider);
    final hwQuery = ref.watch(headwordQueryProvider);
    final defQuery = ref.watch(definitionQueryProvider);

    if (hwQuery.trim().isEmpty && defQuery.trim().isEmpty) {
      return [];
    }

    if (hwQuery.trim().isNotEmpty && defQuery.trim().isNotEmpty) {
      return SearchService.searchCombined(
        dictCode: dictCode,
        hwInput: hwQuery.trim(),
        defInput: defQuery.trim(),
        inputTranslit: settings.inputTranslit,
        hwMode: settings.headwordSearchMode,
        maxResults: settings.maxResults,
      );
    }

    if (hwQuery.trim().isNotEmpty) {
      return SearchService.searchHeadword(
        dictCode: dictCode,
        inputWord: hwQuery.trim(),
        inputTranslit: settings.inputTranslit,
        mode: settings.headwordSearchMode,
        maxResults: settings.maxResults,
      );
    }

    // Definition search
    return SearchService.searchDefinition(
      dictCode: dictCode,
      inputWord: defQuery.trim(),
      inputTranslit: settings.inputTranslit,
      mode: settings.definitionSearchMode,
      maxResults: settings.maxResults,
    );
  },
);

/// Only show tabs that have results for the current search.
final filteredTabsProvider = FutureProvider<List<String>>((ref) async {
  final settings = ref.watch(settingsProvider);
  final activeCodes = settings.activeDictCodes;
  if (activeCodes.isEmpty) return [];

  final hwQuery = ref.watch(headwordQueryProvider);
  final defQuery = ref.watch(definitionQueryProvider);
  final closedTabs = ref.watch(closedTabsProvider);

  if (hwQuery.trim().isEmpty && defQuery.trim().isEmpty) {
    return [];
  }

  // Run searches in parallel to see which dicts have results
  final results = await Future.wait(
    activeCodes.map((code) => ref.read(searchResultsProvider(code).future)),
  );

  final filtered = <String>[];
  for (int i = 0; i < activeCodes.length; i++) {
    final code = activeCodes[i];
    if (results[i].isNotEmpty && !closedTabs.contains(code)) {
      filtered.add(code);
    }
  }
  return filtered;
});
