import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/download_service.dart';
import '../core/database_helper.dart';
import '../core/dictionary_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_provider.dart';

/// Tracks which dictionaries are currently downloaded.
final availableDictsProvider = FutureProvider<Set<String>>((ref) async {
  final available = <String>{};
  for (final info in DictionaryRegistry.all) {
    if (await DatabaseHelper.isAvailable(info.codeLo)) {
      available.add(info.codeLo);
    }
  }
  return available;
});

/// Download progress per dictionary: null = idle, 0.0–1.0 = downloading.
final downloadProgressProvider =
    StateProvider.family<double?, String>((ref, dictCode) => null);

/// Download status message per dictionary.
final downloadStatusProvider =
    StateProvider.family<String, String>((ref, dictCode) => '');

/// Local dictionary metadata (e.g. download date).
final localMetadataProvider =
    FutureProvider.family<DateTime?, String>((ref, dictCode) async {
  final prefs = await SharedPreferences.getInstance();
  final iso = prefs.getString('download_date_$dictCode');
  return iso != null ? DateTime.tryParse(iso) : null;
});

/// Remote dictionary metadata (size and last modified).
final remoteMetadataProvider =
    FutureProvider.family<({int? size, DateTime? lastModified}), String>(
        (ref, dictCode) async {
  final info = DictionaryRegistry.byCode(dictCode);
  if (info == null) return (size: null, lastModified: null);
  return DownloadService.fetchRemoteMetadata(info);
});

/// Action: download a specific dictionary and refresh available list.
class DownloadNotifier {
  final Ref _ref;
  DownloadNotifier(this._ref);

  // Track if downloadAll is currently running (static so it's shared across instances)
  static final _isDownloadAllRunning = StateProvider<bool>((ref) => false);
  // Track if downloadAll has been canceled (static so it's shared across instances)
  static final _downloadAllCancelToken = StateProvider<bool>((ref) => false);

  bool get isDownloadAllRunning =>
      _ref.read(DownloadNotifier._isDownloadAllRunning);

  Future<void> download(String dictCode) async {

    final info = DictionaryRegistry.byCode(dictCode);
    if (info == null) return;

    final tokenProvider = _cancelTokens.putIfAbsent(
      dictCode,
      () => _cancelTokenProvider(dictCode),
    );
    final cancelToken = ValueNotifier<bool>(_ref.read(tokenProvider));

    try {
      await DownloadService.downloadDictionary(
        info: info,
        onProgress: (progress, status) {
          _ref.read(downloadProgressProvider(dictCode).notifier).state =
              progress;
          _ref.read(downloadStatusProvider(dictCode).notifier).state = status;
        },
        cancelToken: cancelToken,
      );
    } finally {
      // Save download date upon success
      final isAvailable = await DatabaseHelper.isAvailable(dictCode);
      if (isAvailable) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'download_date_$dictCode', DateTime.now().toIso8601String());
        _ref.invalidate(localMetadataProvider(dictCode));

        // Auto-enable the dictionary after download
        _ref.read(settingsProvider.notifier).addActiveDict(dictCode);
      }

      _ref.read(downloadProgressProvider(dictCode).notifier).state = null;
      _ref.invalidate(availableDictsProvider);
    }
  }

  Future<void> downloadAll() async {
    // Set the cancel token to false and running to true at the start
    _ref.read(DownloadNotifier._downloadAllCancelToken.notifier).state = false;
    _ref.read(DownloadNotifier._isDownloadAllRunning.notifier).state = true;

    final available = await _ref.read(availableDictsProvider.future);

    // Get dictionaries that need downloading (not available)
    final toDownload = DictionaryRegistry.all
        .where((d) => !available.contains(d.codeLo))
        .map((d) => d.codeLo)
        .toList();

    // Get dictionaries that need updating (available but outdated)
    final toUpdate = <String>[];
    for (final info in DictionaryRegistry.all) {
      if (available.contains(info.codeLo)) {
        // Dictionary is downloaded, check if update is available
        final localDate =
            await _ref.read(localMetadataProvider(info.codeLo).future);
        final remoteMeta =
            await _ref.read(remoteMetadataProvider(info.codeLo).future);

        // If localDate is null (e.g., manually copied dict), still check for update
        // If remoteMeta.lastModified is after localDate, update is available
        final needsUpdate = remoteMeta.lastModified != null &&
            (localDate == null || remoteMeta.lastModified!.isAfter(localDate));
        if (needsUpdate) {
          toUpdate.add(info.codeLo);
        }
      }
    }

    // Combine lists and remove duplicates
    final allToProcess = (<String>{...toDownload, ...toUpdate}).toList();

    for (final code in allToProcess) {
      // Check if user wants to cancel the entire operation
      if (_ref.read(DownloadNotifier._downloadAllCancelToken)) {
        break;
      }

      // Check if already downloading via progress provider
      if (_ref.read(downloadProgressProvider(code)) == null) {
        await download(code);
      }

      // Check again after download in case it was cancelled during the download
      if (_ref.read(DownloadNotifier._downloadAllCancelToken)) {
        break;
      }
    }

    // Reset the running and cancel tokens after completion
    _ref.read(DownloadNotifier._isDownloadAllRunning.notifier).state = false;
    if (!_ref.read(DownloadNotifier._downloadAllCancelToken)) {
      _ref.read(DownloadNotifier._downloadAllCancelToken.notifier).state =
          false;
    }
  }

  void cancelDownloadAll() {
    // Set the cancel token to true to signal cancellation
    _ref.read(DownloadNotifier._downloadAllCancelToken.notifier).state = true;

    // Also cancel any ongoing individual downloads
    for (final tokenProvider in _cancelTokens.values) {
      _ref.read(tokenProvider.notifier).state = true;
    }
  }

  static final _cancelTokens = <String, StateProvider<bool>>{};

  static StateProvider<bool> _cancelTokenProvider(String dictCode) {
    return StateProvider<bool>((ref) => false);
  }
}

// Provider for tracking downloadAll cancellation state
final downloadAllCancelProvider = StateProvider<bool>((ref) => false);
