import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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
      body: SafeArea(
        child: ListView(
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
                    onChanged: (v) => notifier
                        .update(settings.copyWith(headwordSearchMode: v)),
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
            // 5. List Mode
            SwitchListTile(
              title: const Text('List Mode'),
              subtitle: const Text('Show only headwords (accordion view)'),
              value: settings.listMode,
              onChanged: (v) => notifier.update(settings.copyWith(listMode: v)),
            ),
            const Divider(),
            // 6. Accent show/hide
            SwitchListTile(
              title: const Text('Vedic Accents'),
              value: settings.showAccent,
              onChanged: (v) =>
                  notifier.update(settings.copyWith(showAccent: v)),
            ),
            // 7. Highlight
            SwitchListTile(
              title: const Text('Highlight Search Results'),
              value: settings.highlightEnabled,
              onChanged: (v) =>
                  notifier.update(settings.copyWith(highlightEnabled: v)),
            ),
            const Divider(),
            // 8. Max Results
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
            // 9. Font Size
            ListTile(
              title: const Text('Font Size'),
              subtitle: Slider(
                value: settings.fontSize.toDouble(),
                min: 14,
                max: 40,
                divisions: 26,
                label: '${settings.fontSize}px',
                onChanged: (v) {
                  notifier.update(settings.copyWith(fontSize: v.round()));
                },
              ),
              trailing: Text(
                '${settings.fontSize}px',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            // 10. Theme Mode
            ListTile(
              title: const Text('App Theme'),
              trailing: DropdownButton<AppThemeMode>(
                value: settings.themeMode,
                onChanged: (v) {
                  if (v != null) {
                    notifier.update(settings.copyWith(themeMode: v));
                  }
                },
                items: AppThemeMode.values
                    .map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.label)))
                    .toList(),
              ),
            ),
            // 11. Custom Theme Colors (only show when Custom theme is selected)
            if (settings.themeMode == AppThemeMode.custom) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Custom Theme Colors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Start with a preset or pick your own colors:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              // Preset buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: CustomThemePresets.all.map((preset) {
                    return OutlinedButton(
                      onPressed: () {
                        notifier.update(settings.copyWith(
                          customPrimaryColor: preset.primary.toARGB32(),
                          customBackgroundColor: preset.background.toARGB32(),
                          customHeadwordColor: preset.headword.toARGB32(),
                          customSanskritTextColor:
                              preset.sanskritText.toARGB32(),
                        ));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: Text(preset.name),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Color pickers
              _ColorPickerTile(
                label: 'Primary Color',
                subtitle: 'App bar, buttons, links',
                color: settings.customPrimary,
                onColorChanged: (color) {
                  notifier.update(settings.copyWith(
                    customPrimaryColor: color.toARGB32(),
                  ));
                },
              ),
              _ColorPickerTile(
                label: 'Background Color',
                subtitle: 'Main screen background',
                color: settings.customBackground,
                onColorChanged: (color) {
                  notifier.update(settings.copyWith(
                    customBackgroundColor: color.toARGB32(),
                  ));
                },
              ),
              _ColorPickerTile(
                label: 'Headword Color',
                subtitle: 'Headwords within definitions',
                color: settings.customHeadword,
                onColorChanged: (color) {
                  notifier.update(settings.copyWith(
                    customHeadwordColor: color.toARGB32(),
                  ));
                },
              ),
              _ColorPickerTile(
                label: 'Sanskrit Text Color',
                subtitle: 'Sanskrit text in definitions',
                color: settings.customSanskritText,
                onColorChanged: (color) {
                  notifier.update(settings.copyWith(
                    customSanskritTextColor: color.toARGB32(),
                  ));
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
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

class _ColorPickerTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final void Function(Color) onColorChanged;

  const _ColorPickerTile({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = color;
        return AlertDialog(
          title: Text('Pick $label'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: selectedColor,
              onColorChanged: (color) => selectedColor = color,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.both: false,
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.custom: true,
                ColorPickerType.wheel: true,
              },
              enableShadesSelection: true,
              showColorCode: true,
              colorCodeHasColor: true,
              heading: Text(
                'Select color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subheading: Text(
                'Select shade',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
