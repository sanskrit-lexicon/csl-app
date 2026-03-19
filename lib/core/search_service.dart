import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/search_result.dart';
import 'database_helper.dart';
import 'transliteration_service.dart';

/// Runs headword and definition searches against a dictionary SQLite DB.
class SearchService {
  /// Build the LIKE pattern string for a given [mode] and [slpWord].
  static String _likePattern(String slpWord, SearchMode mode) {
    switch (mode) {
      case SearchMode.exact:
        return slpWord;
      case SearchMode.prefix:
        return '$slpWord%';
      case SearchMode.suffix:
        return '%$slpWord';
      case SearchMode.substring:
        return '%$slpWord%';
    }
  }

  /// Search the headword (key) column.
  ///
  /// [inputWord] is the user's typed word in [inputTranslit].
  /// It is converted to SLP1 before querying.
  static Future<List<SearchResult>> searchHeadword({
    required String dictCode,
    required String inputWord,
    required String inputTranslit,
    required SearchMode mode,
    required int maxResults,
  }) async {
    if (inputWord.trim().isEmpty) return [];

    // For English→Sanskrit dicts (ae, mwe, bor) don't transliterate
    final isEnglish = ['ae', 'mwe', 'bor'].contains(dictCode.toLowerCase());
    final slpWord = isEnglish
        ? inputWord.trim().toLowerCase()
        : TransliterationService.toSlp1(inputWord.trim(), inputTranslit);

    if (slpWord.isEmpty) return [];

    final db = await DatabaseHelper.openDict(dictCode);
    final table = dictCode.toLowerCase();
    final pattern = _likePattern(slpWord, mode);

    final List<Map<String, dynamic>> rows;
    if (kDebugMode) {
      debugPrint('SQL Query [$dictCode]: SELECT key, lnum, data FROM $table WHERE key ${mode == SearchMode.exact ? "=" : "LIKE"} "$pattern"');
    }

    if (mode == SearchMode.exact) {
      rows = await db.rawQuery(
        'SELECT key, lnum, data FROM $table WHERE key = ? LIMIT ?',
        [pattern, maxResults],
      );
    } else {
      rows = await db.rawQuery(
        'SELECT key, lnum, data FROM $table WHERE key LIKE ? LIMIT ?',
        [pattern, maxResults],
      );
    }
    
    if (kDebugMode) {
      debugPrint('SQL Result [$dictCode]: ${rows.length} rows');
    }

    return rows.map(SearchResult.fromMap).toList();
  }

  /// Search the definition body (data column).
  ///
  /// For Sanskrit dicts: converts [inputWord] to SLP1 and searches inside data.
  /// For English dicts: raw ASCII substring search (LIKE '%word%').
  static Future<List<SearchResult>> searchDefinition({
    required String dictCode,
    required String inputWord,
    required String inputTranslit,
    required SearchMode mode,
    required int maxResults,
  }) async {
    if (inputWord.trim().isEmpty) return [];

    final isEnglish = ['ae', 'mwe', 'bor'].contains(dictCode.toLowerCase());
    final searchWord = isEnglish
        ? inputWord.trim().toLowerCase()
        : TransliterationService.toSlp1(inputWord.trim(), inputTranslit);

    if (searchWord.isEmpty) return [];

    final db = await DatabaseHelper.openDict(dictCode);
    final table = dictCode.toLowerCase();
    // Definition search always uses substring / LIKE for content search
    final pattern = '%$searchWord%';

    if (kDebugMode) {
      debugPrint('SQL Query [$dictCode]: SELECT key, lnum, data FROM $table WHERE data LIKE "$pattern"');
    }

    final rows = await db.rawQuery(
      'SELECT key, lnum, data FROM $table WHERE data LIKE ? LIMIT ?',
      [pattern, maxResults],
    );

    if (kDebugMode) {
      debugPrint('SQL Result [$dictCode]: ${rows.length} rows');
    }

    return rows.map(SearchResult.fromMap).toList();
  }

  /// Combined search: results where both HW and DEF conditions match.
  static Future<List<SearchResult>> searchCombined({
    required String dictCode,
    required String hwInput,
    required String defInput,
    required String inputTranslit,
    required SearchMode hwMode,
    required int maxResults,
  }) async {
    final isEnglish = ['ae', 'mwe', 'bor'].contains(dictCode.toLowerCase());
    final hwSlp = isEnglish
        ? hwInput.trim().toLowerCase()
        : TransliterationService.toSlp1(hwInput.trim(), inputTranslit);
    final defSlp = isEnglish
        ? defInput.trim().toLowerCase()
        : TransliterationService.toSlp1(defInput.trim(), inputTranslit);

    if (hwSlp.isEmpty || defSlp.isEmpty) return [];

    final db = await DatabaseHelper.openDict(dictCode);
    final table = dictCode.toLowerCase();
    final hwPattern = _likePattern(hwSlp, hwMode);
    final defPattern = '%$defSlp%';

    if (kDebugMode) {
      debugPrint('SQL Query [$dictCode]: SELECT ... FROM $table WHERE key LIKE "$hwPattern" AND data LIKE "$defPattern"');
    }

    final List<Map<String, dynamic>> rows;
    if (hwMode == SearchMode.exact) {
      rows = await db.rawQuery(
        'SELECT key, lnum, data FROM $table WHERE key = ? AND data LIKE ? LIMIT ?',
        [hwSlp, defPattern, maxResults],
      );
    } else {
      rows = await db.rawQuery(
        'SELECT key, lnum, data FROM $table WHERE key LIKE ? AND data LIKE ? LIMIT ?',
        [hwPattern, defPattern, maxResults],
      );
    }
    
    if (kDebugMode) {
      debugPrint('SQL Result [$dictCode]: ${rows.length} rows');
    }

    return rows.map(SearchResult.fromMap).toList();
  }

  /// Fetch a single entry by exact SLP1 key — used for tap-to-lookup.
  static Future<SearchResult?> fetchByKey({
    required String dictCode,
    required String slp1Key,
  }) async {
    final db = await DatabaseHelper.openDict(dictCode);
    final table = dictCode.toLowerCase();
    final rows = await db.rawQuery(
      'SELECT key, lnum, data FROM $table WHERE key = ? LIMIT 1',
      [slp1Key],
    );
    if (rows.isEmpty) return null;
    return SearchResult.fromMap(rows.first);
  }

  /// Fetch abbreviation expansion from {dict}ab database.
  /// Returns expanded text (extracted from `<disp>...</disp>`) or null.
  static Future<String?> fetchAbbreviation({
    required String dictCode,
    required String abbr,
  }) async {
    try {
      final db = await DatabaseHelper.openAbDict(dictCode);
      final table = '${dictCode.toLowerCase()}ab';
      final rows = await db.rawQuery(
        'SELECT data FROM $table WHERE id = ? LIMIT 1',
        [abbr],
      );
      if (rows.isEmpty) return null;
      final raw = rows.first['data'] as String;
      // Extract text from <disp>...</disp>
      final match = RegExp(r'<disp>(.*?)</disp>').firstMatch(raw);
      return match?.group(1)?.trim();
    } catch (_) {
      return null;
    }
  }
}
