import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dictionary_registry.dart';

/// Loads csl-sqlite's `dictionaries.json` and merges it into
/// [DictionaryRegistry], so new dictionaries need no app release.
///
/// Order: fresh network copy (cached on success) -> last cached copy ->
/// built-in list. Never throws; the app always starts with a usable list.
class DictionaryManifest {
  static const String url =
      'https://sanskrit-lexicon.github.io/csl-sqlite/dictionaries.json';
  static const String _cacheKey = 'dictionary_manifest_v1';
  static const int _supportedSchema = 1;

  /// Apply the cached manifest immediately (no network), then try to refresh.
  static Future<void> load({
    Duration timeout = const Duration(seconds: 4),
    http.Client? client,
  }) async {
    final prefs = await _prefs();
    final cached = prefs?.getString(_cacheKey);
    if (cached != null) _apply(cached);

    final c = client ?? http.Client();
    try {
      final resp = await c.get(Uri.parse(url)).timeout(timeout);
      if (resp.statusCode == 200 && _apply(utf8.decode(resp.bodyBytes))) {
        await prefs?.setString(_cacheKey, utf8.decode(resp.bodyBytes));
      }
    } catch (e) {
      debugPrint('DictionaryManifest: using ${cached != null ? "cached" : "built-in"} list ($e)');
    } finally {
      if (client == null) c.close();
    }
  }

  /// Parse and apply [body]. Returns false (and changes nothing) if invalid
  /// or from a newer, incompatible schema.
  static bool _apply(String body) {
    try {
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) return false;
      final v = json['schemaVersion'];
      if (v is! int || v > _supportedSchema) return false;
      DictionaryRegistry.applyManifest(json);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }
}
