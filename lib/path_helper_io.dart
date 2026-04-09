// Native (Android / iOS / macOS / Windows / Linux) data directory resolver.
// Uses path_provider to find the app documents directory.
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> getNativeDataDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = p.join(docs.path, 'sanslex');
  await Directory(dir).create(recursive: true);
  return dir;
}
