import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dictionary_registry.dart';
import '../../models/app_settings.dart';
import '../../providers/search_provider.dart';
import '../../providers/settings_provider.dart';
import '../dictionaries/manage_dictionaries_screen.dart';
import 'widgets/app_drawer.dart';
import 'widgets/entry_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final _hwController = TextEditingController();
  final _defController = TextEditingController();
  TabController? _tabController;
  List<String> _currentTabs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _hwController.dispose();
    _defController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabs(List<String> activeCodes) {
    if (_currentTabs.length != activeCodes.length ||
        !_currentTabs.every((c) => activeCodes.contains(c))) {
      final oldIndex = _tabController?.index ?? 0;
      _tabController?.dispose();
      _tabController = TabController(
        length: activeCodes.length,
        vsync: this,
        initialIndex: oldIndex < activeCodes.length ? oldIndex : 0,
      );
      _currentTabs = List.from(activeCodes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final filteredTabsAsync = ref.watch(filteredTabsProvider);
    final filteredTabs = filteredTabsAsync.value ?? [];
    _syncTabs(filteredTabs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cologne Sanskrit Lexicon'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSearchBars(),
          if (_tabController != null && _currentTabs.isNotEmpty)
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: _currentTabs.map((code) {
                final info = DictionaryRegistry.byCode(code)!;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(info.codeUp),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(closedTabsProvider.notifier)
                              .update((s) => {...s, code});
                        },
                        child: const Icon(Icons.close, size: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          Expanded(
            child: Container(
              color: settings.themeMode == AppThemeMode.cologne
                  ? Colors.white
                  : null,
              child: _buildBody(settings, settings.headwordSearchMode,
                  settings.definitionSearchMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        children: [
          // Headword row
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              controller: _hwController,
              decoration: InputDecoration(
                hintText: 'Type headword to search',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _hwController.clear();
                    ref.read(headwordQueryProvider.notifier).state = '';
                  },
                ),
              ),
              onChanged: (val) {
                ref.read(headwordQueryProvider.notifier).state = val.trim();
                ref.read(closedTabsProvider.notifier).state = {};
              },
              onSubmitted: (val) {
                ref.read(headwordQueryProvider.notifier).state = val.trim();
              },
            ),
          ),
          // Definition row
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              controller: _defController,
              decoration: InputDecoration(
                hintText: 'Type word to search in definition',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.manage_search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _defController.clear();
                    ref.read(definitionQueryProvider.notifier).state = '';
                  },
                ),
              ),
              onChanged: (val) {
                ref.read(definitionQueryProvider.notifier).state = val.trim();
                ref.read(closedTabsProvider.notifier).state = {};
              },
              onSubmitted: (val) {
                ref.read(definitionQueryProvider.notifier).state = val.trim();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      AppSettings settings, SearchMode hwMode, SearchMode defMode) {
    if (settings.activeDictCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_add, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No dictionaries active.'),
            const SizedBox(height: 8),
            const Text(
              'Add dictionaries of your choice to start searching!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageDictionariesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.library_books),
              label: const Text('Add or Manage Dictionaries'),
            ),
          ],
        ),
      );
    }

    final hwQuery = ref.watch(headwordQueryProvider);
    final defQuery = ref.watch(definitionQueryProvider);

    if (hwQuery.trim().isEmpty && defQuery.trim().isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Enter at least 3 characters to begin searching.'),
          ],
        ),
      );
    }

    if (_currentTabs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No word matches the query.'),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: _currentTabs.map((dictCode) {
        return _DictionaryView(
            dictCode: dictCode,
            onWordTap: (word) {
              _hwController.text = word;
              _defController.clear();
            });
      }).toList(),
    );
  }
}

class _DictionaryView extends ConsumerWidget {
  final String dictCode;
  final void Function(String) onWordTap;

  const _DictionaryView({required this.dictCode, required this.onWordTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchResultsProvider(dictCode));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (results) {
        if (results.isEmpty) {
          final hw = ref.watch(headwordQueryProvider);
          final def = ref.watch(definitionQueryProvider);
          if (hw.isEmpty && def.isEmpty) {
            return const Center(child: Text('Type to search...'));
          }
          return const Center(child: Text('No results found.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return EntryCardWidget(
              key: ValueKey('${dictCode}_${results[index].lnum}'),
              dictCode: dictCode,
              searchResult: results[index],
              highlightTerm: ref.watch(definitionQueryProvider).trim(),
              onWordTap: onWordTap,
            );
          },
        );
      },
    );
  }
}
