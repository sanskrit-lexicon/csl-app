// Web implementation of dictionary download/delete operations.
// This file is compiled on web (dart.library.io is absent).
// It downloads from the csl-sqlite GitHub Releases and writes bytes
// into the browser's IndexedDB via sqflite_common_ffi_web.
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// Conditional import so sqflite_common_ffi_web (web-only) is only imported on web.
// sqflite_web_writer.dart uses sqflite_common_ffi_web; its stub does not.
import 'sqflite_web_writer_stub.dart'
    if (dart.library.js_interop) 'sqflite_web_writer.dart';

import '../models/dictionary_info.dart';

/// Base URL for csl-sqlite dictionary ZIPs served via GitHub Pages.
/// Each dictionary has a zip named {code}.zip at this URL.
///
/// Using gh-pages (not Releases) because both csl-app and csl-sqlite are
/// hosted under sanskrit-lexicon.github.io — the same origin — so no CORS
/// preflight is needed. GitHub Releases redirects through
/// objects.githubusercontent.com which lacks CORS headers and blocks
/// browser fetch() calls.
const _sqliteReleaseBase =
    'https://sanskrit-lexicon.github.io/csl-sqlite';

/// Downloads {info.codeLo}.zip from csl-sqlite GitHub Releases,
/// extracts all .sqlite files from the zip, and writes them to IndexedDB.
Future<void> downloadDictionaryNative({
  required DictionaryInfo info,
  required void Function(double progress, String status) onProgress,
  required ValueNotifier<bool> cancelToken,
}) async {
  final code = info.codeLo;
  final url = '$_sqliteReleaseBase/$code.zip';

  onProgress(0.0, 'Connecting…');
  debugPrint('WebDownload: fetching $url');

  final request = http.Request('GET', Uri.parse(url));
  final response = await request.send();

  if (response.statusCode != 200) {
    throw Exception('Download failed: HTTP ${response.statusCode} for $code.zip');
  }

  final total = response.contentLength ?? 0;
  int received = 0;
  final chunks = <List<int>>[];

  await for (final chunk in response.stream) {
    if (cancelToken.value) throw Exception('Download cancelled');
    chunks.add(chunk);
    received += chunk.length;
    if (total > 0) {
      onProgress(
        received / total * 0.85,
        'Downloading… ${_fmtBytes(received)} / ${_fmtBytes(total)}',
      );
    } else {
      onProgress(0.4, 'Downloading… ${_fmtBytes(received)}');
    }
  }

  onProgress(0.85, 'Extracting…');

  // Assemble chunks into a single Uint8List
  final bytes = Uint8List(received);
  int offset = 0;
  for (final chunk in chunks) {
    bytes.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }

  // Decode the zip using the archive package (pure Dart — works on web)
  final archive = ZipDecoder().decodeBytes(bytes);

  int written = 0;
  for (final file in archive) {
    if (!file.isFile || !file.name.endsWith('.sqlite')) continue;

    // Handle nested paths inside the zip (e.g. web/sqlite/mw.sqlite → mw.sqlite)
    final fileName = file.name.split('/').last;
    final dbName = 'sanslex/$fileName';
    final content = Uint8List.fromList(file.content as List<int>);

    // Write to IndexedDB via sqflite_web_writer.dart (web-only extension method)
    await writeDbBytesToIndexedDb(dbName, content);
    debugPrint('WebDownload: wrote $fileName → IndexedDB[$dbName] (${_fmtBytes(content.length)})');
    written++;
  }

  if (written == 0) {
    throw Exception('No .sqlite files found inside $code.zip — check csl-sqlite release format');
  }

  onProgress(1.0, 'Done ($written file${written == 1 ? '' : 's'} saved)');
}

/// On web, deleting from IndexedDB is not supported via our current sqflite API.
/// This is a no-op; users clear browser storage via browser settings.
Future<void> deleteDictionaryNative(String dictCode) async {
  debugPrint('WebDelete: delete not supported on web for $dictCode');
}

/// On web, on-disk size is not applicable; always returns null.
Future<int?> downloadedSizeNative(String dictCode) async => null;

/// On web, we fetch remote metadata directly using an HTTP HEAD request
/// to the GitHub Pages URL. Because it's same-origin (sanskrit-lexicon.github.io),
/// this works seamlessly without CORS issues.
Future<DateTime?>? _globalLastModifiedFuture;

Future<DateTime?> _fetchGlobalLastModified() async {
  try {
    // mw.zip is a large dictionary guaranteed to exist.
    // We make exactly one HEAD request to fetch the global generation date.
    final url = '$_sqliteReleaseBase/mw.zip';
    final response = await http.head(Uri.parse(url));
    if (response.statusCode == 200) {
      final lastModified = response.headers['last-modified'];
      return lastModified != null ? _parseHttpDate(lastModified) : null;
    }
  } catch (e) {
    debugPrint('WebMetadata: global date fetch failed: $e');
  }
  return null;
}

Future<({int? size, DateTime? lastModified})> fetchRemoteMetadataNative(
    DictionaryInfo info) async {
  // All concurrent dictionary queries will await the exact same Future
  _globalLastModifiedFuture ??= _fetchGlobalLastModified();
  final lastModified = await _globalLastModifiedFuture;
  
  return (size: null, lastModified: lastModified);
}

DateTime? _parseHttpDate(String dateStr) {
  try {
    // Standard RFC-1123 HTTP-date: "Wed, 21 Oct 2015 07:28:00 GMT"
    final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US");
    return format.parseUtc(dateStr);
  } catch (e) {
    debugPrint('WebMetadata: Failed to parse last-modified date: $dateStr');
    return null;
  }
}

String _fmtBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
