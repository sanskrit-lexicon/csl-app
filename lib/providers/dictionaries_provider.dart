import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/download_service.dart';
import '../core/database_helper.dart';
import '../core/dictionary_registry.dart';

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

/// Remote file size provider.
final remoteSizeProvider = FutureProvider.family<int?, String>((ref, dictCode) async {
  final info = DictionaryRegistry.byCode(dictCode);
  if (info == null) return null;
  return DownloadService.fetchRemoteSize(info);
});

/// Action: download a specific dictionary and refresh available list.
class DownloadNotifier {
  final Ref _ref;
  DownloadNotifier(this._ref);

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
      _ref.read(downloadProgressProvider(dictCode).notifier).state = null;
      _ref.invalidate(availableDictsProvider);
    }
  }

  Future<void> downloadAll() async {
    final available = await _ref.read(availableDictsProvider.future);
    final toDownload = DictionaryRegistry.all
        .where((d) => !available.contains(d.codeLo))
        .map((d) => d.codeLo)
        .toList();

    for (final code in toDownload) {
      // Check if already downloading via progress provider
      if (_ref.read(downloadProgressProvider(code)) == null) {
        await download(code);
      }
    }
  }

  static final _cancelTokens = <String, StateProvider<bool>>{};

  static StateProvider<bool> _cancelTokenProvider(String dictCode) {
    return StateProvider<bool>((ref) => false);
  }
}
