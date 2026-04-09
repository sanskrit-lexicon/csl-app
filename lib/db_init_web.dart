// Web database factory init.
// Sets the global databaseFactory to the IndexedDB / WASM implementation.
//
// Note: databaseFactory (the global setter) is exported by sqflite_common_ffi.
// databaseFactoryFfiWeb (the web implementation) is from sqflite_common_ffi_web.
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initDatabaseFactory() async {
  // Assign the web (IndexedDB/WASM) factory to the global databaseFactory.
  // We use createDatabaseFactoryFfiWeb to enforce BasicWebWorker.
  // 
  // BUGFIX: Google Chrome supports SharedWorkers, but frequently fails to 
  // load sqlite3.wasm or access IndexedDB correctly within them (especially as a PWA).
  // Safari and Firefox intrinsically lack SharedWorker support so they fallback to
  // BasicWorkers and succeed. This explicitly forces Chrome to do the same!
  databaseFactory = createDatabaseFactoryFfiWeb(
    options: SqfliteFfiWebOptions(
      sharedWorkerUri: Uri.parse('sqflite_sw.js'),
      // ignore: invalid_use_of_visible_for_testing_member
      forceAsBasicWorker: true,
    ),
  );
}
