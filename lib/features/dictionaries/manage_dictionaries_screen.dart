import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dictionary_registry.dart';
import '../../core/download_service.dart';
import '../../providers/dictionaries_provider.dart';
import '../../providers/settings_provider.dart';

class ManageDictionariesScreen extends ConsumerWidget {
  const ManageDictionariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableAsync = ref.watch(availableDictsProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Dictionaries')),
      body: availableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading status: $err')),
        data: (availableCodes) {
          // Sort dictionaries: Active ones first, then alphabetical by name
          final sortedDicts = List.of(DictionaryRegistry.all)..sort((a, b) {
              final aActive = settings.activeDictCodes.contains(a.codeLo);
              final bActive = settings.activeDictCodes.contains(b.codeLo);
              if (aActive && !bActive) return -1;
              if (!aActive && bActive) return 1;
              return a.name.compareTo(b.name);
            });

          return ListView.builder(
            itemCount: sortedDicts.length,
            itemBuilder: (context, index) {
              final info = sortedDicts[index];
              final isAvailable = availableCodes.contains(info.codeLo);
              final isActive = settings.activeDictCodes.contains(info.codeLo);
              final progress =
                  ref.watch(downloadProgressProvider(info.codeLo));
              final status =
                  ref.watch(downloadStatusProvider(info.codeLo));
              final isDownloading = progress != null;

              return ListTile(
                title: Text(info.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${info.codeUp} • ${info.year}'),
                    if (isDownloading) ...[
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: progress),
                      Text(status, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAvailable && !isDownloading)
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          ref
                              .read(downloadNotifierProvider)
                              .download(info.codeLo);
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
                            settingsNotifier.removeActiveDict(info.codeLo);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, ref, info.codeLo),
                      ),
                    ]
                  ],
                ),
              );
            },
          );
        },
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
