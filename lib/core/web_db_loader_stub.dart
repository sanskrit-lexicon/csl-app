// Stub for non-web platforms.
// The real implementation lives in web_db_loader.dart which is only compiled
// on web via the conditional import in database_helper.dart.
// This stub is compiled on native platforms and should never be called at runtime.
Future<bool> loadDbFromAssetIfNeeded(String dbName, String assetPath) async {
  throw UnsupportedError(
      'loadDbFromAssetIfNeeded is a web-only function and should not be called on native platforms.');
}
