import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;

/// Loads a SQLite database from Flutter assets into IndexedDB (web only).
///
/// On web, sqflite_common_ffi_web stores databases in the browser's IndexedDB
/// using a virtual path as the key. This function:
/// 1. Checks if the database already exists in IndexedDB (i.e. was loaded before)
/// 2. If not, reads the .sqlite bytes from the asset bundle
/// 3. Writes the bytes into IndexedDB via databaseFactory.writeDatabaseBytes()
///
/// [dbName]    — virtual IndexedDB key, e.g. 'sanslex/mw.sqlite'
/// [assetPath] — Flutter asset path, e.g. 'assets/sqlite/mw.sqlite'
///
/// Returns true if the DB is now available in IndexedDB, false if the asset
/// does not exist (e.g. optional ab / authtooltips / bib files).
Future<bool> loadDbFromAssetIfNeeded(String dbName, String assetPath) async {
  assert(kIsWeb, 'loadDbFromAssetIfNeeded must only be called on web');

  // Already in IndexedDB from a previous load — nothing to do.
  final exists = await databaseFactory.databaseExists(dbName);
  if (exists) return true;

  // Attempt to load the asset bytes.
  try {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    // Write bytes into IndexedDB. This persists across page reloads.
    await databaseFactory.writeDatabaseBytes(dbName, bytes);
    debugPrint('WebDbLoader: seeded $assetPath → IndexedDB[$dbName]');
    return true;
  } on FlutterError {
    // Asset not found — normal for optional databases (ab, authtooltips, bib).
    debugPrint('WebDbLoader: $assetPath not found in bundle (optional — skipped)');
    return false;
  } catch (e) {
    debugPrint('WebDbLoader: error loading $assetPath: $e');
    return false;
  }
}
