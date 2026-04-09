// Stub for web platform — these functions should never be called on web
// because DownloadService guards all call-sites with `if (kIsWeb) return`.
// If somehow called, they throw immediately rather than silently fail.
import 'package:flutter/foundation.dart';
import '../models/dictionary_info.dart';

Future<void> downloadDictionaryNative({
  required DictionaryInfo info,
  required void Function(double, String) onProgress,
  required ValueNotifier<bool> cancelToken,
}) async =>
    throw UnsupportedError('downloadDictionaryNative is not available on web');

Future<void> deleteDictionaryNative(String dictCode) async =>
    throw UnsupportedError('deleteDictionaryNative is not available on web');

Future<int?> downloadedSizeNative(String dictCode) async => null;

Future<({int? size, DateTime? lastModified})> fetchRemoteMetadataNative(
    DictionaryInfo info) async =>
    (size: null, lastModified: null);
