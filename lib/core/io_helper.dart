// Native (Android / iOS / macOS / Windows / Linux) I/O operations.
// Contains all dart:io usage from the original download_service.dart,
// extracted here so it is never compiled into the web/WASM build.
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../models/dictionary_info.dart';
import 'database_helper.dart';

/// Downloads a dictionary zip from the CSL server and extracts the sqlite files.
/// This is the original DownloadService.downloadDictionary logic, unchanged.
Future<void> downloadDictionaryNative({
  required DictionaryInfo info,
  required void Function(double progress, String status) onProgress,
  required ValueNotifier<bool> cancelToken,
}) async {
  final url = info.downloadUrl;
  onProgress(0.0, 'Connecting…');

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

  final bytes = Uint8List(received);
  int offset = 0;
  for (final chunk in chunks) {
    bytes.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }

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
    'web/sqlite/${codeLo}bib.sqlite': p.join(docsDir, '${codeLo}bib.sqlite'),
  };

  for (final file in archive) {
    final fileName = p.basename(file.name);
    final isMain = fileName == '$codeLo.sqlite';
    final isAb = fileName == '${codeLo}ab.sqlite';
    final isAuth = fileName == '${codeLo}authtooltips.sqlite';
    final isBib = fileName == '${codeLo}bib.sqlite';

    if ((isMain || isAb || isAuth || isBib) && file.isFile) {
      String dest;
      if (isMain) {
        dest = targets['web/sqlite/$codeLo.sqlite']!;
      } else if (isAb) {
        dest = targets['web/sqlite/${codeLo}ab.sqlite']!;
      } else if (isAuth) {
        dest = targets['web/sqlite/${codeLo}authtooltips.sqlite']!;
      } else {
        dest = targets['web/sqlite/${codeLo}bib.sqlite']!;
      }
      final outFile = File(dest);
      await outFile.writeAsBytes(file.content as List<int>);
    }
  }

  for (final key in targets.keys) {
    final dest = targets[key]!;
    if (!await File(dest).exists()) {
      if (key.endsWith('ab.sqlite') || key.endsWith('authtooltips.sqlite')) {
        debugPrint(
            'Note: ${p.basename(dest)} not found in zip. Normal for some dictionaries.');
      } else {
        debugPrint(
            'Extraction error: ${p.basename(dest)} not found in expected path in zip');
      }
    }
  }

  onProgress(1.0, 'Done');
}

/// Deletes all sqlite files for a dictionary from disk (native only).
Future<void> deleteDictionaryNative(String dictCode) async {
  await DatabaseHelper.closeDict(dictCode);
  final paths = [
    await DatabaseHelper.dbPath(dictCode),
    await DatabaseHelper.abDbPath(dictCode),
    await DatabaseHelper.authTooltipsDbPath(dictCode),
    await DatabaseHelper.bibDbPath(dictCode),
  ];
  for (final path in paths) {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}

/// Returns the total on-disk size of all sqlite files for a dictionary.
Future<int?> downloadedSizeNative(String dictCode) async {
  final mainPath = await DatabaseHelper.dbPath(dictCode);
  final main = File(mainPath);
  if (!await main.exists()) return null;

  int total = (await main.stat()).size;
  for (final path in [
    await DatabaseHelper.abDbPath(dictCode),
    await DatabaseHelper.authTooltipsDbPath(dictCode),
    await DatabaseHelper.bibDbPath(dictCode),
  ]) {
    final f = File(path);
    if (await f.exists()) total += (await f.stat()).size;
  }
  return total;
}

/// Fetches remote zip size and last-modified date via HTTP HEAD.
Future<({int? size, DateTime? lastModified})> fetchRemoteMetadataNative(
    DictionaryInfo info) async {
  try {
    debugPrint('fetchRemoteMetadata: fetching ${info.downloadUrl}');
    final response = await http.head(Uri.parse(info.downloadUrl));
    debugPrint(
        'fetchRemoteMetadata: ${info.codeLo} statusCode=${response.statusCode}');
    if (response.statusCode == 200) {
      final len = response.headers['content-length'];
      final modified = response.headers['last-modified'];
      debugPrint(
          'fetchRemoteMetadata: ${info.codeLo} len=$len, modified=$modified');
      return (
        size: len != null ? int.tryParse(len) : null,
        lastModified: modified != null ? HttpDate.parse(modified) : null,
      );
    }
  } catch (e) {
    debugPrint('fetchRemoteMetadata: ${info.codeLo} error=$e');
  }
  return (size: null, lastModified: null);
}

String _fmtBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Stub for native platforms - LS links not needed on native.
Future<bool> downloadLsLinksNative({
  required String dictCode,
  required void Function(double progress, String status) onProgress,
}) async {
  return false;
}
