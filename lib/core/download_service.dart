import 'package:flutter/foundation.dart';
// Conditional import: native I/O operations (download, delete, size check).
// io_helper.dart      → compiled on Android / iOS / macOS / Windows / Linux
// io_helper_stub.dart → compiled on web (stubs that throw if called)
import 'io_helper_stub.dart' if (dart.library.io) 'io_helper.dart';
import '../models/dictionary_info.dart';
import 'database_helper.dart';

/// Manages downloading and deleting dictionary SQLite files.
///
/// On web: downloads from csl-sqlite GitHub Releases, writes to IndexedDB.
/// On native: downloads from Cologne server, extracts to app documents dir.
class DownloadService {
  /// Download dictionary SQLite files.
  /// On web: fetches {code}.zip from csl-sqlite releases, writes .sqlite bytes to IndexedDB.
  /// On native: downloads zip from Cologne server, extracts .sqlite files to disk.
  static Future<void> downloadDictionary({
    required DictionaryInfo info,
    required void Function(double progress, String status) onProgress,
    required ValueNotifier<bool> cancelToken,
  }) async {
    return downloadDictionaryNative(
        info: info, onProgress: onProgress, cancelToken: cancelToken);
  }

  /// Delete all sqlite files for a dictionary.
  /// On native: deletes from disk. On web: no-op (IndexedDB deletion not supported via API).
  static Future<void> deleteDictionary(String dictCode) async {
    return deleteDictionaryNative(dictCode);
  }

  /// Returns combined file size in bytes. Returns null on web or if not downloaded.
  static Future<int?> downloadedSize(String dictCode) async {
    if (kIsWeb) return null;
    return downloadedSizeNative(dictCode);
  }

  /// Returns true if the main sqlite is available (on disk / in IndexedDB+assets).
  static Future<bool> isDownloaded(String dictCode) async {
    return DatabaseHelper.isAvailable(dictCode);
  }

  /// Fetches remote zip size and last-modified date. Returns nulls on web.
  static Future<({int? size, DateTime? lastModified})> fetchRemoteMetadata(
      DictionaryInfo info) async {
    if (kIsWeb) return (size: null, lastModified: null);
    return fetchRemoteMetadataNative(info);
  }

  /// Downloads LS links database for a dictionary if available.
  /// Called automatically after dictionary download.
  /// Returns true if LS links were downloaded, false if not available.
  static Future<bool> downloadLsLinks({
    required String dictCode,
    required void Function(double progress, String status) onProgress,
  }) async {
    // Check if LS links database exists for this dictionary
    if (!DatabaseHelper.lsLinkDicts.contains(dictCode.toLowerCase())) {
      return false;
    }
    // On web, use the native download function
    if (kIsWeb) {
      return downloadLsLinksNative(dictCode: dictCode, onProgress: onProgress);
    }
    // On native, LS links are not needed (handled differently)
    return false;
  }

  static String _fmtBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatBytes(int bytes) => _fmtBytes(bytes);
}
