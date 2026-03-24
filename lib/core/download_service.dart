import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../models/dictionary_info.dart';
import 'database_helper.dart';

/// Manages downloading and deleting dictionary SQLite files.
class DownloadService {
  /// Download zip from CSL server, extract both sqlite files.
  ///
  /// URL pattern:
  ///   https://www.sanskrit-lexicon.uni-koeln.de/scans/{DICTUP}Scan/{YEAR}/downloads/{dictlo}web1.zip
  ///
  /// Zip internal path:
  ///   web/sqlite/{dictlo}.sqlite
  ///   web/sqlite/{dictlo}ab.sqlite
  static Future<void> downloadDictionary({
    required DictionaryInfo info,
    required void Function(double progress, String status) onProgress,
    required ValueNotifier<bool> cancelToken,
  }) async {
    final url = info.downloadUrl;
    onProgress(0.0, 'Connecting…');

    // --- Download zip with progress ---
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Download failed: HTTP ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    int received = 0;
    final chunks = <List<int>>[];

    await for (final chunk in response.stream) {
      if (cancelToken.value) throw Exception('Download cancelled');
      chunks.add(chunk);
      received += chunk.length;
      if (total > 0) {
        onProgress(received / total * 0.9,
            'Downloading… ${_fmtBytes(received)} / ${_fmtBytes(total)}');
      } else {
        onProgress(0.5, 'Downloading… ${_fmtBytes(received)}');
      }
    }

    onProgress(0.9, 'Extracting…');

    // --- Build Uint8List from chunks ---
    final bytes = Uint8List(received);
    int offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    // --- Extract from zip ---
    final archive = ZipDecoder().decodeBytes(bytes);
    final docsDir = await DatabaseHelper.dataDir;
    debugPrint('DB Directory: $docsDir');
    await Directory(docsDir).create(recursive: true);

    final codeLo = info.codeLo;
    final targets = {
      'web/sqlite/$codeLo.sqlite': p.join(docsDir, '$codeLo.sqlite'),
      'web/sqlite/${codeLo}ab.sqlite': p.join(docsDir, '${codeLo}ab.sqlite'),
      'web/sqlite/${codeLo}authtooltips.sqlite':
          p.join(docsDir, '${codeLo}authtooltips.sqlite'),
    };

    for (final file in archive) {
      // Some zips have nested folders, so we look for the filename match
      // irrespective of exact zip directory structure.
      final fileName = p.basename(file.name);
      final isMain = fileName == '$codeLo.sqlite';
      final isAb = fileName == '${codeLo}ab.sqlite';
      final isAuth = fileName == '${codeLo}authtooltips.sqlite';

      if ((isMain || isAb || isAuth) && file.isFile) {
        String dest;
        if (isMain) {
          dest = targets['web/sqlite/$codeLo.sqlite']!;
        } else if (isAb) {
          dest = targets['web/sqlite/${codeLo}ab.sqlite']!;
        } else {
          dest = targets['web/sqlite/${codeLo}authtooltips.sqlite']!;
        }
        final outFile = File(dest);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }

    // Verify main file was extracted. Abbreviation/AuthTooltips files might not exist in some zips.
    for (final key in targets.keys) {
      final dest = targets[key]!;
      if (!await File(dest).exists()) {
        if (key.endsWith('ab.sqlite') || key.endsWith('authtooltips.sqlite')) {
          debugPrint(
              'Note: ${p.basename(dest)} not found in zip. This is normal for some dictionaries.');
        } else {
          debugPrint(
              'Extraction error: ${p.basename(dest)} not found in expected path in zip');
        }
      }
    }

    onProgress(1.0, 'Done');
  }

  /// Delete all sqlite files and close any cached DB connections.
  static Future<void> deleteDictionary(String dictCode) async {
    await DatabaseHelper.closeDict(dictCode);
    final mainPath = await DatabaseHelper.dbPath(dictCode);
    final abPath = await DatabaseHelper.abDbPath(dictCode);
    final authPath = await DatabaseHelper.authTooltipsDbPath(dictCode);
    final main = File(mainPath);
    final ab = File(abPath);
    final auth = File(authPath);
    if (await main.exists()) await main.delete();
    if (await ab.exists()) await ab.delete();
    if (await auth.exists()) await auth.delete();
  }

  /// Returns combined file size in bytes, or null if not downloaded.
  static Future<int?> downloadedSize(String dictCode) async {
    final mainPath = await DatabaseHelper.dbPath(dictCode);
    final abPath = await DatabaseHelper.abDbPath(dictCode);
    final authPath = await DatabaseHelper.authTooltipsDbPath(dictCode);
    final main = File(mainPath);
    final ab = File(abPath);
    final auth = File(authPath);
    if (!await main.exists()) return null;

    final mainStat = await main.stat();
    int totalSize = mainStat.size;
    if (await ab.exists()) {
      final abStat = await ab.stat();
      totalSize += abStat.size;
    }
    if (await auth.exists()) {
      final authStat = await auth.stat();
      totalSize += authStat.size;
    }
    return totalSize;
  }

  /// Returns true if both sqlite files exist for [dictCode].
  static Future<bool> isDownloaded(String dictCode) async {
    return DatabaseHelper.isAvailable(dictCode);
  }

  /// Fetches the remote zip file size and last-modified date using a HEAD request.
  static Future<({int? size, DateTime? lastModified})> fetchRemoteMetadata(
      DictionaryInfo info) async {
    try {
      final response = await http.head(Uri.parse(info.downloadUrl));
      if (response.statusCode == 200) {
        final len = response.headers['content-length'];
        final modified = response.headers['last-modified'];

        return (
          size: len != null ? int.tryParse(len) : null,
          lastModified: modified != null ? _parseHttpDate(modified) : null,
        );
      }
    } catch (_) {}
    return (size: null, lastModified: null);
  }

  static DateTime? _parseHttpDate(String dateStr) {
    try {
      // http.head returns dates in RFC 1123 format usually,
      // e.g. "Wed, 21 Oct 2015 07:28:00 GMT"
      // HttpDate.parse handles this but requires dart:io
      return HttpDate.parse(dateStr);
    } catch (_) {
      return DateTime.tryParse(dateStr);
    }
  }

  static String _fmtBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatBytes(int bytes) => _fmtBytes(bytes);
}
