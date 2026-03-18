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
          ListTile(
            title: const Text('Headword Search Mode'),
            subtitle: const Text('How to match headwords'),
            trailing: DropdownButton<SearchMode>(
              value: settings.headwordSearchMode,
              onChanged: (v) {
                if (v != null) notifier.update(settings.copyWith(headwordSearchMode: v));
              },
              items: SearchMode.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
            ),
          ),
          // 2. Definition Search
          ListTile(
            title: const Text('Definition Search Mode'),
            subtitle: const Text('How to match in dictionary definitions'),
            trailing: DropdownButton<SearchMode>(
              value: settings.definitionSearchMode,
              onChanged: (v) {
                if (v != null) notifier.update(settings.copyWith(definitionSearchMode: v));
              },
              items: SearchMode.values
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                  .toList(),
            ),
          ),
          const Divider(),
          // 3. Input Transliteration
          ListTile(
            title: const Text('Input Transliteration'),
            subtitle: const Text('Scheme used for typing inside the search box'),
            trailing: DropdownButton<String>(
              value: settings.inputTranslit,
              onChanged: (v) {
                if (v != null) notifier.update(settings.copyWith(inputTranslit: v));
              },
              items: TransliterationService.availableSchemes
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(TransliterationService.displayName(s))))
                  .toList(),
            ),
          ),
          // 4. Output Transliteration
          ListTile(
            title: const Text('Output Transliteration'),
            subtitle: const Text('Display script used for dictionary results'),
            trailing: DropdownButton<String>(
              value: settings.outputTranslit,
              onChanged: (v) {
                if (v != null) notifier.update(settings.copyWith(outputTranslit: v));
              },
              items: TransliterationService.availableSchemes
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(TransliterationService.displayName(s))))
                  .toList(),
            ),
          ),
          const Divider(),
          // 5. Accent show/hide
          SwitchListTile(
            title: const Text('Vedic Accents'),
            subtitle: const Text('Show pitch accent marks if available in dictionary'),
            value: settings.showAccent,
            onChanged: (v) => notifier.update(settings.copyWith(showAccent: v)),
          ),
          // 6. Highlight
          SwitchListTile(
            title: const Text('Highlight Search Results'),
            subtitle: const Text('Visually mark found terms inside definitions'),
            value: settings.highlightEnabled,
            onChanged: (v) => notifier.update(settings.copyWith(highlightEnabled: v)),
          ),
          const Divider(),
          // 7. Max Results
          ListTile(
            title: const Text('Maximum Results'),
            subtitle: Text('Limit search to ${settings.maxResults} entries'),
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
            subtitle: const Text('Choose light, dark, or follow system theme'),
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
