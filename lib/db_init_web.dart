import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initDatabaseFactory() async {
  debugPrint('DB_INIT: Initializing sqflite_common_ffi_web factory...');
  try {
    final options = SqfliteFfiWebOptions(
      sharedWorkerUri: Uri.parse('sqflite_sw.js'),
      sqlite3WasmUri: Uri.parse('sqlite3.wasm'),
      // ignore: invalid_use_of_visible_for_testing_member
      forceAsBasicWorker: true,
    );
    final factory = createDatabaseFactoryFfiWeb(options: options);
    databaseFactory = factory;
    debugPrint('DB_INIT: databaseFactory successfully assigned.');
  } catch (e, stack) {
    debugPrint(
        'DB_INIT_ERROR: Exception setting up database factory: $e\n$stack');
  }
}
