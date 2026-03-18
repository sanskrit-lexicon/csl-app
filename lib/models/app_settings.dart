import 'package:flutter/foundation.dart';

/// Search mode for headword or definition search.
enum SearchMode { exact, prefix, suffix, substring }

extension SearchModeX on SearchMode {
  String get label {
    switch (this) {
      case SearchMode.exact:
        return 'Exact';
      case SearchMode.prefix:
        return 'Prefix';
      case SearchMode.suffix:
        return 'Suffix';
      case SearchMode.substring:
        return 'Substring';
    }
  }

  String get value {
    return name;
  }

  static SearchMode fromValue(String v) {
    return SearchMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => SearchMode.prefix,
    );
  }
}

/// All user preferences / settings for the app.
@immutable
class AppSettings {
  final SearchMode headwordSearchMode;
  final SearchMode definitionSearchMode;
  final String inputTranslit; // e.g. 'hk'
  final String outputTranslit; // e.g. 'devanagari'
  final bool showAccent;
  final bool highlightEnabled;
  final int maxResults;
  final List<String> activeDictCodes; // ordered list of open tabs

  const AppSettings({
    this.headwordSearchMode = SearchMode.prefix,
    this.definitionSearchMode = SearchMode.substring,
    this.inputTranslit = 'hk',
    this.outputTranslit = 'devanagari',
    this.showAccent = false,
    this.highlightEnabled = true,
    this.maxResults = 100,
    this.activeDictCodes = const [],
  });

  AppSettings copyWith({
    SearchMode? headwordSearchMode,
    SearchMode? definitionSearchMode,
    String? inputTranslit,
    String? outputTranslit,
    bool? showAccent,
    bool? highlightEnabled,
    int? maxResults,
    List<String>? activeDictCodes,
  }) {
    return AppSettings(
      headwordSearchMode: headwordSearchMode ?? this.headwordSearchMode,
      definitionSearchMode: definitionSearchMode ?? this.definitionSearchMode,
      inputTranslit: inputTranslit ?? this.inputTranslit,
      outputTranslit: outputTranslit ?? this.outputTranslit,
      showAccent: showAccent ?? this.showAccent,
      highlightEnabled: highlightEnabled ?? this.highlightEnabled,
      maxResults: maxResults ?? this.maxResults,
      activeDictCodes: activeDictCodes ?? this.activeDictCodes,
    );
  }
}
