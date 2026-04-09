// Web database factory init.
// Sets the global databaseFactory to the IndexedDB / WASM implementation.
//
// Note: databaseFactory (the global setter) is exported by sqflite_common_ffi.
// databaseFactoryFfiWeb (the web implementation) is from sqflite_common_ffi_web.
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

Future<void> initDatabaseFactory() async {
  // Assign the web (IndexedDB/WASM) factory to the global databaseFactory.
  // This must be called before any database is opened.
  databaseFactory = databaseFactoryFfiWeb;
}
