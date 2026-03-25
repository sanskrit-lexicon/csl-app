import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
      debugPrint(
          'SQL Query [$dictCode]: SELECT key, lnum, data FROM $table WHERE key ${mode == SearchMode.exact ? "=" : "LIKE"} "$pattern"');
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
  ///
  /// Note: [outputTranslit] is used for definition search to match against displayed text.
  /// If user types in Devanagari (which they see), we convert from Devanagari to SLP1.
  static Future<List<SearchResult>> searchDefinition({
    required String dictCode,
    required String inputWord,
    required String inputTranslit,
    required String outputTranslit,
    required SearchMode mode,
    required int maxResults,
  }) async {
    if (inputWord.trim().isEmpty) return [];

    final isEnglish = ['ae', 'mwe', 'bor'].contains(dictCode.toLowerCase());
    // Use outputTranslit for definition search to match displayed text
    final searchWord = isEnglish
        ? inputWord.trim().toLowerCase()
        : TransliterationService.toSlp1(inputWord.trim(), outputTranslit);

    if (searchWord.isEmpty) return [];

    final db = await DatabaseHelper.openDict(dictCode);
    final table = dictCode.toLowerCase();
    // Definition search always uses substring / LIKE for content search
    final pattern = '%$searchWord%';

    if (kDebugMode) {
      debugPrint(
          'SQL Query [$dictCode]: SELECT key, lnum, data FROM $table WHERE LOWER(data) LIKE LOWER("$pattern")');
    }

    final rows = await db.rawQuery(
      'SELECT key, lnum, data FROM $table WHERE LOWER(data) LIKE LOWER(?) LIMIT ?',
      [pattern, maxResults],
    );

    if (kDebugMode) {
      debugPrint('SQL Result [$dictCode]: ${rows.length} rows');
    }

    return rows.map(SearchResult.fromMap).toList();
  }

  /// Combined search: results where both HW and DEF conditions match.
  ///
  /// Note: [outputTranslit] is used for definition search to match against displayed text.
  static Future<List<SearchResult>> searchCombined({
    required String dictCode,
    required String hwInput,
    required String defInput,
    required String inputTranslit,
    required String outputTranslit,
    required SearchMode hwMode,
    required int maxResults,
  }) async {
    final isEnglish = ['ae', 'mwe', 'bor'].contains(dictCode.toLowerCase());
    final hwSlp = isEnglish
        ? hwInput.trim().toLowerCase()
        : TransliterationService.toSlp1(hwInput.trim(), inputTranslit);
    // Use outputTranslit for definition search to match displayed text
    final defSlp = isEnglish
        ? defInput.trim().toLowerCase()
        : TransliterationService.toSlp1(defInput.trim(), outputTranslit);

    if (hwSlp.isEmpty || defSlp.isEmpty) return [];

    final db = await DatabaseHelper.openDict(dictCode);
    final table = dictCode.toLowerCase();
    final hwPattern = _likePattern(hwSlp, hwMode);
    final defPattern = '%$defSlp%';

    if (kDebugMode) {
      debugPrint(
          'SQL Query [$dictCode]: SELECT ... FROM $table WHERE key LIKE "$hwPattern" AND LOWER(data) LIKE LOWER("$defPattern")');
    }

    final List<Map<String, dynamic>> rows;
    if (hwMode == SearchMode.exact) {
      rows = await db.rawQuery(
        'SELECT key, lnum, data FROM $table WHERE key = ? AND LOWER(data) LIKE LOWER(?) LIMIT ?',
        [hwSlp, defPattern, maxResults],
      );
    } else {
      rows = await db.rawQuery(
        'SELECT key, lnum, data FROM $table WHERE key LIKE ? AND LOWER(data) LIKE LOWER(?) LIMIT ?',
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

  /// Fetch literary source expansion from {dict}authtooltips or {dict}bib database.
  /// Returns full name (e.g., "Whitney's Grammar, section 502") or null if not found.
  static Future<String?> fetchLsExpansion({
    required String dictCode,
    required String code,
  }) async {
    debugPrint(
        '=== SEARCH SERVICE: fetchLsExpansion called with dictCode=$dictCode, code=$code');

    // Try authtooltips database first
    String? result = await _queryLsFromDb(dictCode, code, 'authtooltips');
    if (result != null) {
      debugPrint('=== SEARCH SERVICE: Found result in authtooltips: $result');
      return result;
    }

    // Try bib database (e.g., pwgbib.sqlite for PWG)
    result = await _queryLsFromDb(dictCode, code, 'bib');
    if (result != null) {
      debugPrint('=== SEARCH SERVICE: Found result in bib: $result');
      return result;
    }

    debugPrint('=== SEARCH SERVICE: No result found in any database');
    return null;
  }

  /// Helper to query LS from a specific database type (authtooltips or bib).
  static Future<String?> _queryLsFromDb(
      String dictCode, String code, String dbType) async {
    try {
      Database? db;
      String table;

      if (dbType == 'authtooltips') {
        db = await DatabaseHelper.openAuthTooltips(dictCode);
        if (db == null) return null;
        table = '${dictCode.toLowerCase()}authtooltips';
      } else {
        db = await DatabaseHelper.openBib(dictCode);
        if (db == null) return null;
        table = '${dictCode.toLowerCase()}bib';
      }

      debugPrint(
          '=== SEARCH SERVICE: Querying $dbType table $table with code=$code');

      // First, discover the column names in the table
      final columnsInfo = await db.rawQuery('PRAGMA table_info($table)');
      final columnNames = columnsInfo.map((c) => c['name'] as String).toList();
      debugPrint('=== SEARCH SERVICE: $dbType Table columns: $columnNames');

      // Try different column name patterns
      String? result;

      // Pattern 1: key + data columns
      if (columnNames.contains('key') && columnNames.contains('data')) {
        final rows = await db.rawQuery(
          'SELECT data, type FROM $table WHERE key = ? LIMIT 1',
          [code],
        );
        debugPrint(
            '=== SEARCH SERVICE: $dbType key+data query returned ${rows.length} rows');
        if (rows.isNotEmpty) {
          final data = rows.first['data'] as String?;
          final type = rows.first['type'] as String?;
          if (data != null && type != null) {
            result = '$data ($type)';
          } else if (data != null) {
            result = data;
          }
        }
      }

      // Pattern 2: code + title + type columns
      if (result == null &&
          columnNames.contains('code') &&
          columnNames.contains('title')) {
        final rows = await db.rawQuery(
          'SELECT title, type FROM $table WHERE code = ? LIMIT 1',
          [code],
        );
        debugPrint(
            '=== SEARCH SERVICE: $dbType code+title query returned ${rows.length} rows');
        if (rows.isNotEmpty) {
          final title = rows.first['title'] as String?;
          final type = rows.first['type'] as String?;
          if (title != null && type != null) {
            result = '$title ($type)';
          } else if (title != null) {
            result = title;
          }
        }
      }

      // Pattern 3: text column
      if (result == null && columnNames.contains('text')) {
        final rows = await db.rawQuery(
          'SELECT text FROM $table WHERE key = ? LIMIT 1',
          [code],
        );
        debugPrint(
            '=== SEARCH SERVICE: $dbType text query returned ${rows.length} rows');
        if (rows.isNotEmpty) {
          result = rows.first['text'] as String?;
        }
      }

      // Pattern 4: name column
      if (result == null && columnNames.contains('name')) {
        final rows = await db.rawQuery(
          'SELECT name FROM $table WHERE key = ? LIMIT 1',
          [code],
        );
        debugPrint(
            '=== SEARCH SERVICE: $dbType name query returned ${rows.length} rows');
        if (rows.isNotEmpty) {
          result = rows.first['name'] as String?;
        }
      }

      // Pattern 5: description column
      if (result == null && columnNames.contains('description')) {
        final rows = await db.rawQuery(
          'SELECT description FROM $table WHERE key = ? LIMIT 1',
          [code],
        );
        debugPrint(
            '=== SEARCH SERVICE: $dbType description query returned ${rows.length} rows');
        if (rows.isNotEmpty) {
          result = rows.first['description'] as String?;
        }
      }

      // Pattern 6: expansion column
      if (result == null && columnNames.contains('expansion')) {
        final rows = await db.rawQuery(
          'SELECT expansion FROM $table WHERE key = ? LIMIT 1',
          [code],
        );
        debugPrint(
            '=== SEARCH SERVICE: $dbType expansion query returned ${rows.length} rows');
        if (rows.isNotEmpty) {
          result = rows.first['expansion'] as String?;
        }
      }

      return result;
    } catch (e) {
      debugPrint('=== SEARCH SERVICE: $dbType Exception: $e');
      return null;
    }
  }
}
