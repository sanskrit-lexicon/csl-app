import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Manages SQLite database connections for each dictionary.
class DatabaseHelper {
  static const String _subdir = 'sanslex';
  static final Map<String, Database> _openDbs = {};

  /// Returns the app documents subdirectory path for sanslex data.
  static Future<String> get dataDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = p.join(docs.path, _subdir);
    return dir;
  }

  /// Full path to {dictCode}.sqlite in app documents directory.
  static Future<String> dbPath(String dictCode) async {
    return p.join(await dataDir, '${dictCode.toLowerCase()}.sqlite');
  }

  /// Full path to {dictCode}ab.sqlite in app documents directory.
  static Future<String> abDbPath(String dictCode) async {
    return p.join(await dataDir, '${dictCode.toLowerCase()}ab.sqlite');
  }

  /// Full path to {dictCode}authtooltips.sqlite in app documents directory.
  static Future<String> authTooltipsDbPath(String dictCode) async {
    return p.join(
        await dataDir, '${dictCode.toLowerCase()}authtooltips.sqlite');
  }

  /// Returns true if the main .sqlite file exists for this dictionary.
  static Future<bool> isAvailable(String dictCode) async {
    final main = await dbPath(dictCode);
    final mainExists = await databaseExists(main);
    return mainExists;
  }

  /// Opens (or returns cached) main dictionary database.
  static Future<Database> openDict(String dictCode) async {
    final code = dictCode.toLowerCase();
    if (_openDbs.containsKey(code)) return _openDbs[code]!;
    final path = await dbPath(code);
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: true,
        onOpen: (db) async {
          await db.execute('PRAGMA case_sensitive_like = ON;');
        },
      ),
    );
    _openDbs[code] = db;
    return db;
  }

  /// Opens (or returns cached) abbreviations database.
  static Future<Database> openAbDict(String dictCode) async {
    final code = '${dictCode.toLowerCase()}ab';
    if (_openDbs.containsKey(code)) return _openDbs[code]!;
    final path = await abDbPath(dictCode);
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: true,
        onOpen: (db) async {
          await db.execute('PRAGMA case_sensitive_like = ON;');
        },
      ),
    );
    _openDbs[code] = db;
    return db;
  }

  /// Opens (or returns cached) authtooltips database.
  static Future<Database?> openAuthTooltips(String dictCode) async {
    final code = '${dictCode.toLowerCase()}authtooltips';
    if (_openDbs.containsKey(code)) return _openDbs[code]!;
    final path = await authTooltipsDbPath(dictCode);
    final exists = await databaseExists(path);
    if (!exists) return null;
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        readOnly: true,
        onOpen: (db) async {
          await db.execute('PRAGMA case_sensitive_like = ON;');
        },
      ),
    );
    _openDbs[code] = db;
    return db;
  }

  /// Closes and removes a dictionary from cache (call after deletion).
  static Future<void> closeDict(String dictCode) async {
    final code = dictCode.toLowerCase();
    final abCode = '${code}ab';
    final authCode = '${code}authtooltips';
    await _openDbs[code]?.close();
    await _openDbs[abCode]?.close();
    await _openDbs[authCode]?.close();
    _openDbs.remove(code);
    _openDbs.remove(abCode);
    _openDbs.remove(authCode);
  }

  /// Closes all open databases.
  static Future<void> closeAll() async {
    for (final db in _openDbs.values) {
      await db.close();
    }
    _openDbs.clear();
  }
}
