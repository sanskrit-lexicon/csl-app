/// A single search result row from the dictionary SQLite database.
class SearchResult {
  final String key; // SLP1 headword
  final double lnum; // unique entry serial number
  final String data; // raw XML-like entry data

  const SearchResult({
    required this.key,
    required this.lnum,
    required this.data,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      key: map['key'] as String,
      lnum: (map['lnum'] as num).toDouble(),
      data: map['data'] as String,
    );
  }
}
