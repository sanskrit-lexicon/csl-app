// ignore_for_file: unused_import
// sqflite_common_ffi_web is imported to bring the SqfliteWebDatabaseFactory
// extension into scope. This enables databaseFactory.writeDatabaseBytes().
// Extensions don't appear as "used" by name, so the analyzer incorrectly
// flags this as unused. The ignore annotation above suppresses that warning.
import 'dart:typed_data';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Writes [bytes] into IndexedDB under [dbName] using the
/// sqflite_common_ffi_web extension method writeDatabaseBytes().
/// This file is compiled only on web via the conditional import in io_helper_stub.dart.
Future<void> writeDbBytesToIndexedDb(String dbName, Uint8List bytes) async {
  await databaseFactory.writeDatabaseBytes(dbName, bytes);
}
