import 'dart:typed_data';

/// Stub for native platforms — should never be called at runtime.
/// Download on native uses dart:io file writes (in io_helper.dart), not this.
Future<void> writeDbBytesToIndexedDb(String dbName, Uint8List bytes) async {
  throw UnsupportedError('writeDbBytesToIndexedDb is a web-only function');
}
