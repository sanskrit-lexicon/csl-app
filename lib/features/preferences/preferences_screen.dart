import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/transliteration_service.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        children: [
          // 1. Headword Search
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Headword Search Mode'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: _SearchModeSelector(
                  currentMode: settings.headwordSearchMode,
                  onChanged: (v) =>
                      notifier.update(settings.copyWith(headwordSearchMode: v)),
                ),
              ),
            ],
          ),
          // 2. Definition Search
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('Definition Search Mode'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: _SearchModeSelector(
                  currentMode: settings.definitionSearchMode,
                  onChanged: (v) => notifier
                      .update(settings.copyWith(definitionSearchMode: v)),
                ),
              ),
            ],
          ),
          const Divider(),
          // 3. Input Transliteration
          ListTile(
            title: const Text('Input Transliteration'),
            trailing: DropdownButton<String>(
              value: settings.inputTranslit,
              onChanged: (v) {
                if (v != null) {
                  notifier.update(settings.copyWith(inputTranslit: v));
                }
              },
              items: TransliterationService.availableSchemes
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(TransliterationService.displayName(s))))
                  .toList(),
            ),
          ),
          // 4. Output Transliteration
          ListTile(
            title: const Text('Output Transliteration'),
            trailing: DropdownButton<String>(
              value: settings.outputTranslit,
              onChanged: (v) {
                if (v != null) {
                  notifier.update(settings.copyWith(outputTranslit: v));
                }
              },
              items: TransliterationService.availableSchemes
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(TransliterationService.displayName(s))))
                  .toList(),
            ),
          ),
          const Divider(),
          // 5. Accent show/hide
          SwitchListTile(
            title: const Text('Vedic Accents'),
            value: settings.showAccent,
            onChanged: (v) => notifier.update(settings.copyWith(showAccent: v)),
          ),
          // 6. Highlight
          SwitchListTile(
            title: const Text('Highlight Search Results'),
            value: settings.highlightEnabled,
            onChanged: (v) =>
                notifier.update(settings.copyWith(highlightEnabled: v)),
          ),
          const Divider(),
          // 7. Max Results
          ListTile(
            title: const Text('Maximum Results'),
            trailing: SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: settings.maxResults.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                onFieldSubmitted: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null && parsed > 0) {
                    notifier.update(settings.copyWith(maxResults: parsed));
                  }
                },
              ),
            ),
          ),
          const Divider(),
          // 8. Theme Mode
          ListTile(
            title: const Text('App Theme'),
            trailing: DropdownButton<AppThemeMode>(
              value: settings.themeMode,
              onChanged: (v) {
                if (v != null) notifier.update(settings.copyWith(themeMode: v));
              },
              items: AppThemeMode.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchModeSelector extends StatelessWidget {
  final SearchMode currentMode;
  final void Function(SearchMode) onChanged;

  const _SearchModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<SearchMode>(
        segments: SearchMode.values
            .map((mode) => ButtonSegment<SearchMode>(
                  value: mode,
                  label: Text(mode.label, style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        selected: {currentMode},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
