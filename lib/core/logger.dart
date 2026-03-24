import 'package:flutter/foundation.dart';

class AppLogger {
  static bool debugEnabled = false;

  static void debug(String message) {
    if (debugEnabled && kDebugMode) {
      debugPrint(message);
    }
  }

  static void entry(
      String dictCode, double lnum, String key1, String bodyHtml) {
    if (debugEnabled && kDebugMode) {
      debugPrint('=== ENTRY DEBUG ===');
      debugPrint('Dict: $dictCode, Lnum: $lnum');
      debugPrint('Headword (key1): $key1');
      debugPrint('Body HTML:\n$bodyHtml');
      debugPrint('=== END ENTRY DEBUG ===');
    }
  }
}
