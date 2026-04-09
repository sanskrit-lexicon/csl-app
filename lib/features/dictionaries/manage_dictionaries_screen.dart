import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dictionary_registry.dart';
import '../../core/download_service.dart';
import '../../models/dictionary_info.dart';

import '../../providers/dictionaries_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:intl/intl.dart';

class ManageDictionariesScreen extends ConsumerWidget {
  const ManageDictionariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(availableDictsProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dictionaries'),
      ),
      body: SafeArea(
        child: availableAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading status: $err')),
          data: (availableCodes) {
            // Sort dictionaries based on user preference (dictOrder)
            final orderedCodes = settings.dictOrder;
            final sortedDicts = List.of(DictionaryRegistry.all)
              ..sort((a, b) {
                final idxA = orderedCodes.indexOf(a.codeLo);
                final idxB = orderedCodes.indexOf(b.codeLo);

                // If both not in order, fallback to alphabetical
                if (idxA == -1 && idxB == -1) return a.name.compareTo(b.name);
                // If one not in order, put it at the end
                if (idxA == -1) return 1;
                if (idxB == -1) return -1;

                return idxA.compareTo(idxB);
              });

            return Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: sortedDicts.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final list = List<DictionaryInfo>.from(sortedDicts);
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      settingsNotifier
                          .reorderDicts(list.map((d) => d.codeLo).toList());
                    },
                    itemBuilder: (context, index) {
                      final info = sortedDicts[index];
                      final isAvailable = availableCodes.contains(info.codeLo);
                      final isActive =
                          settings.activeDictCodes.contains(info.codeLo);
                      final progress =
                          ref.watch(downloadProgressProvider(info.codeLo));
                      final status =
                          ref.watch(downloadStatusProvider(info.codeLo));
                      final isDownloading = progress != null;

                      return ListTile(
                        key: ValueKey(info.codeLo),
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                        title: Text(info.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(info.codeUp),
                                const Spacer(),
                                if (!isDownloading)
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final remoteMetaAsync = ref.watch(
                                          remoteMetadataProvider(info.codeLo));
                                      return remoteMetaAsync.maybeWhen(
                                        data: (meta) => meta.size != null
                                            ? Text(
                                                DownloadService.formatBytes(
                                                    meta.size!),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey))
                                            : const SizedBox.shrink(),
                                        orElse: () => const SizedBox.shrink(),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final localDateAsync = ref
                                    .watch(localMetadataProvider(info.codeLo));
                                final remoteMetaAsync = ref
                                    .watch(remoteMetadataProvider(info.codeLo));

                                return localDateAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                  data: (localDate) {
                                    if (!isAvailable || localDate == null) {
                                      return const SizedBox.shrink();
                                    }

                                    final fmt = DateFormat('yyyy-MM-dd HH:mm');
                                    final dateStr = fmt.format(localDate);

                                    final remoteDate =
                                        remoteMetaAsync.value?.lastModified;
                                    final hasUpdate = remoteDate != null &&
                                        remoteDate.isAfter(localDate);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Downloaded on $dateStr',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        if (hasUpdate)
                                          const Text('Update Available!',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            if (isDownloading) ...[
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: progress),
                              Text(status,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer(
                              builder: (context, ref, child) {
                                final localDateAsync = ref
                                    .watch(localMetadataProvider(info.codeLo));
                                final remoteMetaAsync = ref
                                    .watch(remoteMetadataProvider(info.codeLo));

                                final localDate = localDateAsync.value;
                                final remoteDate =
                                    remoteMetaAsync.value?.lastModified;
                                // hasUpdate if: remoteDate exists and is newer than local,
                                // OR if remoteDate is null (couldn't fetch - assume update needed)
                                final hasUpdate = isAvailable &&
                                    (remoteDate == null ||
                                        (localDate != null &&
                                            remoteDate.isAfter(localDate)));

                                if (!isDownloading &&
                                    (!isAvailable || hasUpdate)) {
                                  return IconButton(
                                    icon: Icon(hasUpdate
                                        ? Icons.system_update
                                        : Icons.download),
                                    tooltip: hasUpdate
                                        ? 'Update Dictionary'
                                        : 'Download Dictionary',
                                    onPressed: () {
                                      ref
                                          .read(downloadNotifierProvider)
                                          .download(info.codeLo);
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            if (isAvailable) ...[
                              // Toggle Active status (shows in HomeScreen tabs)
                              Switch(
                                value: isActive,
                                onChanged: (v) {
                                  if (v) {
                                    settingsNotifier.addActiveDict(info.codeLo);
                                  } else {
                                    settingsNotifier
                                        .removeActiveDict(info.codeLo);
                                  }
                                },
                              ),
                              // Delete button: hidden on web (IndexedDB not deletable via API)
                              if (!kIsWeb)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _confirmDelete(
                                      context, ref, info.codeLo),
                                ),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Download All CTA Button at the bottom
                Consumer(
                  builder: (context, ref, child) {
                    final downloadNotifier =
                        ref.watch(downloadNotifierProvider);
                    final isDownloadAllRunning =
                        downloadNotifier.isDownloadAllRunning;

                    // Consolidate dictionary status checks into a single pass
                    bool isAnyDownloading = false;
                    final hasUpdates = <String>[];
                    int fetchFailedCount = 0;
                    int fetchSuccessCount = 0;
                    bool hasMissingDictionaries = false;
                    int missingCount = 0;

                    for (final info in DictionaryRegistry.all) {
                      // Check downloading status
                      if (ref.watch(downloadProgressProvider(info.codeLo)) != null) {
                        isAnyDownloading = true;
                      }
                      
                      // Check metadata/updates
                      final localDate = ref.watch(localMetadataProvider(info.codeLo)).value;
                      final remoteMeta = ref.watch(remoteMetadataProvider(info.codeLo)).value;
                      final remoteDate = remoteMeta?.lastModified;
                      final isAvail = availableCodes.contains(info.codeLo);

                      if (!isAvail) {
                        hasMissingDictionaries = true;
                        missingCount++;
                      }

                      if (remoteDate == null && isAvail) {
                        if (!kIsWeb) fetchFailedCount++;
                      } else if (remoteDate != null) {
                        fetchSuccessCount++;
                        if (isAvail && localDate != null && remoteDate.isAfter(localDate)) {
                          hasUpdates.add(info.codeLo);
                        }
                      }
                    }

                    // If remote fetch failed, show appropriate message
                    final bool networkFailed =
                        fetchFailedCount > 0 && fetchSuccessCount == 0;

                    final hasAnythingToDo =
                        hasMissingDictionaries || hasUpdates.isNotEmpty;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (isAnyDownloading || isDownloadAllRunning)
                              ? null
                              : hasAnythingToDo
                                  ? () {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      ref
                                          .read(downloadNotifierProvider)
                                          .downloadAll()
                                          .catchError((e) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text('Download error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      });
                                    }
                                  : null,
                          icon: Icon(
                            isDownloadAllRunning || isAnyDownloading
                                ? Icons.cancel
                                : Icons.download_for_offline,
                          ),
                          label: Text(
                            isDownloadAllRunning || isAnyDownloading
                                ? 'Cancel'
                                : networkFailed
                                    ? 'Cannot reach Database Server'
                                    : hasMissingDictionaries &&
                                            hasUpdates.isNotEmpty
                                        ? 'Download & Update All ($missingCount new, ${hasUpdates.length} updates)'
                                        : hasMissingDictionaries
                                            ? 'Download All ($missingCount new)'
                                            : hasUpdates.isNotEmpty
                                                ? 'Update All (${hasUpdates.length} updates)'
                                                : 'All Up to Date',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (isAnyDownloading || isDownloadAllRunning)
                                    ? Colors.red
                                    : networkFailed
                                        ? Colors.orange
                                        : hasAnythingToDo
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String codeLo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dictionary?'),
        content: const Text(
            'This will delete the local database files for this dictionary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Remove from active tabs first
      await ref.read(settingsProvider.notifier).removeActiveDict(codeLo);
      // Delete database files
      await DownloadService.deleteDictionary(codeLo);
      // Refresh available list
      ref.invalidate(availableDictsProvider);
    }
  }
}

// Provider for the DownloadNotifier to be used inside widgets
final downloadNotifierProvider = Provider((ref) => DownloadNotifier(ref));
