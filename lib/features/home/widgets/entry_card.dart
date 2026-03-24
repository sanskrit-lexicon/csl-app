import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dictionary_registry.dart';
import '../../../models/app_settings.dart';
import '../../../models/search_result.dart';
import '../../../providers/settings_provider.dart';
import '../../../rendering/entry_parser.dart';
import '../../../rendering/entry_renderer.dart';

class EntryCardWidget extends ConsumerWidget {
  final String dictCode;
  final SearchResult searchResult;
  final String? highlightTerm;
  final void Function(String) onWordTap;

  const EntryCardWidget({
    super.key,
    required this.dictCode,
    required this.searchResult,
    this.highlightTerm,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final dictInfo = DictionaryRegistry.byCode(dictCode)!;

    // Parse the raw XML data
    final parsed = EntryParser.parse(searchResult.data, searchResult.lnum);

    // Renderer
    final renderer = EntryRenderer(
      settings: settings,
      dictCode: dictCode,
      useCologneTheme: settings.themeMode == AppThemeMode.cologne,
      customAccentColor: settings.themeMode == AppThemeMode.custom
          ? settings.customSanskritText
          : null,
      customHeadwordColor: settings.themeMode == AppThemeMode.custom
          ? settings.customHeadword
          : null,
    );

    return FutureBuilder<Widget>(
      future: renderer.buildEntryWidget(
        entry: parsed,
        onWordTap: onWordTap,
        onCopy: () {
          final text =
              '${parsed.key1Slp1}\n${parsed.bodyHtml.replaceAll(RegExp(r'<[^>]*>'), '')}';
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        },
        dictCodeUp: dictInfo.codeUp,
        lnum: parsed.lnum,
        highlightTerm: highlightTerm,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error rendering entry: ${snapshot.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
