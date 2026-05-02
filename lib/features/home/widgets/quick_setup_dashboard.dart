import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/transliteration_service.dart';
import '../../../models/app_settings.dart';
import '../../../providers/settings_provider.dart';
import '../../dictionaries/manage_dictionaries_screen.dart';

class QuickSetupDashboard extends ConsumerWidget {
  const QuickSetupDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeHeader(context),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: 'Manage Dictionaries',
            subtitle: 'Add or remove dictionaries from your collection',
            icon: Icons.library_books,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageDictionariesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildTransliterationSection(context, settings, notifier),
          const SizedBox(height: 16),
          _buildSearchModeSection(context, settings, notifier),
          const SizedBox(height: 32),
          Text(
            'Ready to go? Start typing in the search bars above!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Text(
      'Customize your experience with these quick options:',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withAlpha(77),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransliterationSection(
    BuildContext context,
    AppSettings settings,
    SettingsNotifier notifier,
  ) {
    return _buildSettingContainer(
      context,
      title: 'Transliteration',
      icon: Icons.translate,
      child: Column(
        children: [
          _buildDropdownRow(
            context,
            label: 'Input:',
            value: settings.inputTranslit,
            items: TransliterationService.availableSchemes,
            onChanged: (v) {
              if (v != null) {
                notifier.update(settings.copyWith(inputTranslit: v));
              }
            },
          ),
          const Divider(height: 16),
          _buildDropdownRow(
            context,
            label: 'Output:',
            value: settings.outputTranslit,
            items: TransliterationService.availableSchemes,
            onChanged: (v) {
              if (v != null) {
                notifier.update(settings.copyWith(outputTranslit: v));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchModeSection(
    BuildContext context,
    AppSettings settings,
    SettingsNotifier notifier,
  ) {
    return _buildSettingContainer(
      context,
      title: 'Search Mode',
      icon: Icons.manage_search,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Headword:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          _buildSearchModeSelector(
            currentMode: settings.headwordSearchMode,
            onChanged: (v) =>
                notifier.update(settings.copyWith(headwordSearchMode: v)),
          ),
          const SizedBox(height: 16),
          Text('Definition:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          _buildSearchModeSelector(
            currentMode: settings.definitionSearchMode,
            onChanged: (v) =>
                notifier.update(settings.copyWith(definitionSearchMode: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingContainer(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 2,
      shadowColor: color.withAlpha(77),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                onChanged: onChanged,
                items: items
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          TransliterationService.displayName(s),
                          style: const TextStyle(fontSize: 13),
                        )))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchModeSelector({
    required SearchMode currentMode,
    required void Function(SearchMode) onChanged,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<SearchMode>(
        segments: SearchMode.values
            .map((mode) => ButtonSegment<SearchMode>(
                  value: mode,
                  label: Text(mode.label, style: const TextStyle(fontSize: 11)),
                ))
            .toList(),
        selected: {currentMode},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
        ),
      ),
    );
  }
}
