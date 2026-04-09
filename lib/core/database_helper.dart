import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Conditional import: platform-specific data directory resolution.
// On native: uses path_provider + dart:io to find the Documents folder.
// On web:    returns a virtual namespace string ('sanslex') for IndexedDB keys.
import '../path_helper_stub.dart'
    if (dart.library.io) '../path_helper_io.dart'
    if (dart.library.js_interop) '../path_helper_web.dart';
// NOTE: web_db_loader is no longer used here.
// Databases on web are populated by the user via on-demand download
// (download_service.dart / io_helper_stub.dart), not by asset seeding.

/// Manages SQLite database connections for each dictionary.
///
/// On native (Android / iOS / macOS / Windows / Linux):
///   - Databases live as .sqlite files in the app documents directory.
///   - Paths are resolved by path_helper_io.dart via path_provider.
///
/// On web (WASM via IndexedDB):
///   - Databases are stored in the browser's IndexedDB.
///   - The "path" is a virtual key: 'sanslex/{dictCode}.sqlite'.
///   - On first access, the .sqlite file is seeded from Flutter assets
///     (assets/sqlite/{dictCode}.sqlite) into IndexedDB.
///   - Subsequent accesses skip the seed step (already in IndexedDB).
class DatabaseHelper {
  static const String _prefix = 'sanslex_';
  static final Map<String, Database> _openDbs = {};

  // ---------------------------------------------------------------------------
  // Path helpers
  // ---------------------------------------------------------------------------

  /// Returns the data directory path (native) or virtual prefix (web).
  static Future<String> get dataDir async {
    if (kIsWeb) return _prefix;
    return getNativeDataDir(); // platform-specific via conditional import
  }

  /// Full virtual/real path to the main dictionary database.
  static Future<String> dbPath(String dictCode) async {
    final base = await dataDir;
    if (kIsWeb) return './$base${dictCode.toLowerCase()}.sqlite';
    return '$base/${dictCode.toLowerCase()}.sqlite';
  }

  /// Full virtual/real path to the abbreviations database.
  static Future<String> abDbPath(String dictCode) async {
    final base = await dataDir;
    if (kIsWeb) return './$base${dictCode.toLowerCase()}ab.sqlite';
    return '$base/${dictCode.toLowerCase()}ab.sqlite';
  }

  /// Full virtual/real path to the authtooltips database.
  static Future<String> authTooltipsDbPath(String dictCode) async {
    final base = await dataDir;
    if (kIsWeb) return './$base${dictCode.toLowerCase()}authtooltips.sqlite';
    return '$base/${dictCode.toLowerCase()}authtooltips.sqlite';
  }

  /// Full virtual/real path to the bibliography database.
  static Future<String> bibDbPath(String dictCode) async {
    final base = await dataDir;
    if (kIsWeb) return './$base${dictCode.toLowerCase()}bib.sqlite';
    return '$base/${dictCode.toLowerCase()}bib.sqlite';
  }

  // ---------------------------------------------------------------------------
  // Availability check
  // ---------------------------------------------------------------------------

  /// Returns true if the main .sqlite is available.
  /// On web: checks IndexedDB only (fast — no HTTP requests).
  /// On native: checks file existence on disk.
  static Future<bool> isAvailable(String dictCode) async {
    final path = await dbPath(dictCode);
    // On both web and native, databaseFactory.databaseExists checks the
    // appropriate storage (IndexedDB on web, filesystem on native).
    return databaseFactory.databaseExists(path);
  }

  // ---------------------------------------------------------------------------
  // Open helpers
  // ---------------------------------------------------------------------------

  /// Opens (or returns cached) main dictionary database.
  static Future<Database> openDict(String dictCode) async {
    final code = dictCode.toLowerCase();
    if (_openDbs.containsKey(code)) return _openDbs[code]!;

    final path = await dbPath(code);
    // On web: assumes the DB is already in IndexedDB (user downloaded it).
    // On native: opens the file from disk.

    print('DB_OPEN: Opening dictionary database at $path');
    try {
      final exists = await databaseFactory.databaseExists(path);
      print('DB_OPEN: Path exists in IndexedDB: $exists');

      final db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          // Removing readOnly: true for web to prevent Code 14 on some browsers
          readOnly: !kIsWeb,
          onOpen: (db) async {
            await db.execute('PRAGMA case_sensitive_like = ON;');
            final countRes = await db.rawQuery("SELECT count(*) as cnt FROM sqlite_master WHERE type='table' AND name=?", [code]);
            print('DB_OPEN: Table "$code" found: ${countRes.isNotEmpty && countRes.first["cnt"] != 0}');
          },
        ),
      );
      _openDbs[code] = db;
      return db;
    } catch (e, stack) {
      print('DB_OPEN_ERROR: Failed to open dictionary $code: $e\n$stack');
      rethrow;
    }
  }

  /// Opens (or returns cached) abbreviations database.
  static Future<Database> openAbDict(String dictCode) async {
    final code = '${dictCode.toLowerCase()}ab';
    if (_openDbs.containsKey(code)) return _openDbs[code]!;

    final path = await abDbPath(dictCode);
    // On web: assumes the DB is already in IndexedDB.

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: !kIsWeb,
        onOpen: (db) async {
          await db.execute('PRAGMA case_sensitive_like = ON;');
        },
      ),
    );
    _openDbs[code] = db;
    return db;
  }

  /// Opens (or returns cached) authtooltips database.
  /// Returns null if the database does not exist (optional file).
  static Future<Database?> openAuthTooltips(String dictCode) async {
    final code = '${dictCode.toLowerCase()}authtooltips';
    if (_openDbs.containsKey(code)) return _openDbs[code]!;

    final path = await authTooltipsDbPath(dictCode);
    if (kIsWeb) {
      // On web: check IndexedDB — it won't be there unless the zip contained this file.
      if (!await databaseFactory.databaseExists(path)) return null;
    } else {
      if (!await databaseFactory.databaseExists(path)) return null;
    }

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: !kIsWeb,
        onOpen: (db) async {
          await db.execute('PRAGMA case_sensitive_like = ON;');
        },
      ),
    );
    _openDbs[code] = db;
    return db;
  }

  /// Opens (or returns cached) bibliography database.
  /// Returns null if the database does not exist (optional file).
  static Future<Database?> openBib(String dictCode) async {
    final code = '${dictCode.toLowerCase()}bib';
    if (_openDbs.containsKey(code)) return _openDbs[code]!;

    final path = await bibDbPath(dictCode);
    if (!await databaseFactory.databaseExists(path)) return null;

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: !kIsWeb,
        onOpen: (db) async {
          await db.execute('PRAGMA case_sensitive_like = ON;');
        },
      ),
    );
    _openDbs[code] = db;
    return db;
  }

  // ---------------------------------------------------------------------------
  // Close helpers
  // ---------------------------------------------------------------------------

  /// Closes and removes a dictionary from cache (call after deletion on native).
  static Future<void> closeDict(String dictCode) async {
    final code = dictCode.toLowerCase();
    final abCode = '${code}ab';
    final authCode = '${code}authtooltips';
    final bibCode = '${code}bib';
    await _openDbs[code]?.close();
    await _openDbs[abCode]?.close();
    await _openDbs[authCode]?.close();
    await _openDbs[bibCode]?.close();
    _openDbs.remove(code);
    _openDbs.remove(abCode);
    _openDbs.remove(authCode);
    _openDbs.remove(bibCode);
  }

  /// Closes all open databases.
  static Future<void> closeAll() async {
    for (final db in _openDbs.values) {
      await db.close();
    }
    _openDbs.clear();
  }
}
