import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dictionary_registry.dart';
import '../../core/search_service.dart';
import '../../models/search_result.dart';
import 'widgets/entry_card.dart';

class PageHeadwordsScreen extends ConsumerWidget {
  final String dictCode;
  final String pageCol;

  const PageHeadwordsScreen({
    super.key,
    required this.dictCode,
    required this.pageCol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictInfo = DictionaryRegistry.byCode(dictCode)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${dictInfo.codeUp} - Page $pageCol'),
      ),
      body: FutureBuilder<List<SearchResult>>(
        future: SearchService.fetchByPage(dictCode: dictCode, pageCol: pageCol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const Center(child: Text('No entries found for this page.'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              return EntryCardWidget(
                key: ValueKey('${dictCode}_page_${pageCol}_${results[index].lnum}'),
                dictCode: dictCode,
                searchResult: results[index],
                onWordTap: (word) {
                  // For now, just pop and return the word if needed, 
                  // or better, handle it like a search.
                  // But usually, from this screen, we just want to view.
                  // If we tap a word, we might want to search it in the main screen.
                  // Let's just pop and show a message or do nothing for now.
                },
              );
            },
          );
        },
      ),
    );
  }
}
