import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dictionary_registry.dart';
import '../../models/app_settings.dart';
import '../../providers/search_provider.dart';
import '../../providers/settings_provider.dart';
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
    _hwController.addListener(() {
      final text = _hwController.text.trim();
      ref.read(headwordQueryProvider.notifier).state = text;
      ref.read(closedTabsProvider.notifier).state = {};
    });
    _defController.addListener(() {
      final text = _defController.text.trim();
      ref.read(definitionQueryProvider.notifier).state = text;
      ref.read(closedTabsProvider.notifier).state = {};
    });

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
        title: const Text('Sanskrit Lexicon'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              _buildSearchBars(),
              if (_tabController != null && _currentTabs.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
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
                              ref.read(closedTabsProvider.notifier).update((s) => {...s, code});
                            },
                            child: const Icon(Icons.close, size: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(settings, settings.headwordSearchMode, settings.definitionSearchMode),
    );
  }

  Widget _buildSearchBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Headword row
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Headword')),
              Expanded(
                child: TextField(
                  controller: _hwController,
                  decoration: InputDecoration(
                    hintText: 'Search headwords...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                    suffixIcon: _hwController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _hwController.clear();
                              ref.read(headwordQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (val) {
                    ref.read(headwordQueryProvider.notifier).state = val.trim();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Definition row
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Definition')),
              Expanded(
                child: TextField(
                  controller: _defController,
                  decoration: InputDecoration(
                    hintText: 'Search in definition text...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                    suffixIcon: _defController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _defController.clear();
                              ref.read(definitionQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (val) {
                    ref.read(definitionQueryProvider.notifier).state = val.trim();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppSettings settings, SearchMode hwMode, SearchMode defMode) {
    if (settings.activeDictCodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_add, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No dictionaries active.'),
            Text(
              'Please open the side drawer to download and manage dictionaries.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
