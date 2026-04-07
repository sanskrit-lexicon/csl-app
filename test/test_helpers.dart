import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

const zipBasePath = '../csl-lslink/zip';

Future<Database> openDbFromZip(String dbName, String zipFileName) async {
  final zipPath = path.join(zipBasePath, zipFileName);
  final zipFile = File(zipPath);

  if (!zipFile.existsSync()) {
    throw Exception('Zip file not found: $zipPath');
  }

  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final archiveFile = archive.files.firstWhere(
    (f) => f.name.endsWith('.sqlite'),
    orElse: () => throw Exception('No sqlite file found in $zipFileName'),
  );

  final tempDir = Directory.systemTemp.createTempSync('csl_test_');
  final dbPath = path.join(tempDir.path, dbName);

  final outputFile = File(dbPath);
  outputFile.writeAsBytesSync(archiveFile.content as List<int>);

  return databaseFactoryFfi.openDatabase(dbPath);
}
