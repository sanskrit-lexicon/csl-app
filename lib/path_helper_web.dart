// Web path helper — filesystem paths don't exist on web.
// Returns the virtual namespace prefix used in IndexedDB.
Future<String> getNativeDataDir() async => 'sanslex';
