import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

/// Persists and loads [AppSettings] using SharedPreferences.
class SettingsService {
  static const _hwMode = 'hw_search_mode';
  static const _defMode = 'def_search_mode';
  static const _inputTranslit = 'input_translit';
  static const _outputTranslit = 'output_translit';
  static const _showAccent = 'show_accent';
  static const _highlight = 'highlight_enabled';
  static const _maxResults = 'max_results';
  static const _activeDicts = 'active_dicts';
  static const _dictOrder = 'dict_order';
  static const _themeMode = 'theme_mode';
  static const _customPrimaryColor = 'custom_primary_color';
  static const _customBackgroundColor = 'custom_background_color';
  static const _customHeadwordColor = 'custom_headword_color';
  static const _customSanskritTextColor = 'custom_sanskrit_text_color';
  static const _listMode = 'list_mode';
  static const _fontSize = 'font_size';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      headwordSearchMode: SearchModeX.fromValue(
          prefs.getString(_hwMode) ?? SearchMode.prefix.name),
      definitionSearchMode: SearchModeX.fromValue(
          prefs.getString(_defMode) ?? SearchMode.prefix.name),
      inputTranslit: prefs.getString(_inputTranslit) ?? 'itrans',
      outputTranslit: prefs.getString(_outputTranslit) ?? 'devanagari',
      showAccent: prefs.getBool(_showAccent) ?? true,
      highlightEnabled: prefs.getBool(_highlight) ?? true,
      maxResults: prefs.getInt(_maxResults) ?? 100,
      activeDictCodes: _decodeList(prefs.getString(_activeDicts)),
      dictOrder: _decodeList(prefs.getString(_dictOrder)),
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == prefs.getString(_themeMode),
        orElse: () => AppThemeMode.cologne,
      ),
      customPrimaryColor: prefs.getInt(_customPrimaryColor) ?? 0xFF36648B,
      customBackgroundColor: prefs.getInt(_customBackgroundColor) ?? 0xFFFFFFFF,
      customHeadwordColor: prefs.getInt(_customHeadwordColor) ?? 0xFFDBE4ED,
      customSanskritTextColor:
          prefs.getInt(_customSanskritTextColor) ?? 0xFF339933,
      listMode: prefs.getBool(_listMode) ?? false,
      fontSize: prefs.getInt(_fontSize) ?? 16,
    );
  }

  static Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hwMode, s.headwordSearchMode.name);
    await prefs.setString(_defMode, s.definitionSearchMode.name);
    await prefs.setString(_inputTranslit, s.inputTranslit);
    await prefs.setString(_outputTranslit, s.outputTranslit);
    await prefs.setBool(_showAccent, s.showAccent);
    await prefs.setBool(_highlight, s.highlightEnabled);
    await prefs.setInt(_maxResults, s.maxResults);
    await prefs.setString(_activeDicts, jsonEncode(s.activeDictCodes));
    await prefs.setString(_dictOrder, jsonEncode(s.dictOrder));
    await prefs.setString(_themeMode, s.themeMode.name);
    await prefs.setInt(_customPrimaryColor, s.customPrimaryColor);
    await prefs.setInt(_customBackgroundColor, s.customBackgroundColor);
    await prefs.setInt(_customHeadwordColor, s.customHeadwordColor);
    await prefs.setInt(_customSanskritTextColor, s.customSanskritTextColor);
    await prefs.setBool(_listMode, s.listMode);
    await prefs.setInt(_fontSize, s.fontSize);
  }

  static List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }
}
