import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/search_service.dart';
import '../models/search_result.dart';
import 'settings_provider.dart';

/// Current headword search query text.
final headwordQueryProvider = StateProvider<String>((ref) => '');

/// Current definition search query text.
final definitionQueryProvider = StateProvider<String>((ref) => '');

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
      // Both queries set — prioritise headword search
      return SearchService.searchHeadword(
        dictCode: dictCode,
        inputWord: hwQuery.trim(),
        inputTranslit: settings.inputTranslit,
        mode: settings.headwordSearchMode,
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
