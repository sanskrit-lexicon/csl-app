// Native (Android / iOS / macOS / Windows / Linux) database factory init.
// Uses sqflite default factory on mobile, sqflite_common_ffi on desktop.
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // On Android and iOS sqflite uses its default factory — nothing to do.
}
