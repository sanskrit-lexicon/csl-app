import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode, Color;

/// Theme modes for the app.
enum AppThemeMode { cologne, light, dark, custom }

extension AppThemeModeX on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.cologne:
        return 'Cologne';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.custom:
        return 'Custom';
    }
  }

  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.cologne:
        return ThemeMode.light;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.custom:
        return ThemeMode.light;
    }
  }
}

/// Custom theme color presets.
class CustomThemePreset {
  final String name;
  final Color primary;
  final Color background;
  final Color headword;
  final Color sanskritText;

  const CustomThemePreset({
    required this.name,
    required this.primary,
    required this.background,
    required this.headword,
    required this.sanskritText,
  });
}

/// Predefined custom theme presets.
class CustomThemePresets {
  static const cologne = CustomThemePreset(
    name: 'Cologne',
    primary: Color(0xFF36648B),
    background: Color(0xFFFFFFFF),
    headword: Color(0xFFDBE4ED),
    sanskritText: Color(0xFF339933),
  );

  static const light = CustomThemePreset(
    name: 'Light',
    primary: Color(0xFF8B4513),
    background: Color(0xFFFFFFFF),
    headword: Color(0xFFFFFFFF),
    sanskritText: Color(0xFF546E7A),
  );

  static const dark = CustomThemePreset(
    name: 'Dark',
    primary: Color(0xFF8B4513),
    background: Color(0xFF121212),
    headword: Color(0xFF1E1E1E),
    sanskritText: Color(0xFFB0BEC5),
  );

  static const white = CustomThemePreset(
    name: 'White',
    primary: Color(0xFF0000FF),
    background: Color(0xFFFFFFFF),
    headword: Color(0xFFFFFFFF),
    sanskritText: Color(0xFF008000),
  );

  static const List<CustomThemePreset> all = [cologne, light, dark, white];
}

/// Search mode for headword or definition search.
enum SearchMode { prefix, exact, substring, suffix }

extension SearchModeX on SearchMode {
  String get label {
    switch (this) {
      case SearchMode.exact:
        return 'Exact';
      case SearchMode.prefix:
        return 'Prefix';
      case SearchMode.suffix:
        return 'Suffix';
      case SearchMode.substring:
        return 'Substring';
    }
  }

  String get value {
    return name;
  }

  static SearchMode fromValue(String v) {
    return SearchMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => SearchMode.prefix,
    );
  }
}

/// All user preferences / settings for the app.
@immutable
class AppSettings {
  final SearchMode headwordSearchMode;
  final SearchMode definitionSearchMode;
  final String inputTranslit; // e.g. 'hk'
  final String outputTranslit; // e.g. 'devanagari'
  final bool showAccent;
  final bool highlightEnabled;
  final int maxResults;
  final List<String> activeDictCodes;
  final List<String> dictOrder; // Order of all dictionary codes
  final AppThemeMode themeMode;
  final int customPrimaryColor;
  final int customBackgroundColor;
  final int customHeadwordColor;
  final int customSanskritTextColor;
  final bool enableBasicAdjust; // Feature 5: XML pre-processing
  final bool enableBasicDisplay; // Feature 4: XML to HTML rendering

  const AppSettings({
    this.headwordSearchMode = SearchMode.prefix,
    this.definitionSearchMode = SearchMode.prefix,
    this.inputTranslit = 'itrans',
    this.outputTranslit = 'devanagari',
    this.showAccent = true,
    this.highlightEnabled = true,
    this.maxResults = 100,
    this.activeDictCodes = const [],
    this.dictOrder = const [],
    this.themeMode = AppThemeMode.cologne,
    this.customPrimaryColor = 0xFF36648B,
    this.customBackgroundColor = 0xFFFFFFFF,
    this.customHeadwordColor = 0xFFDBE4ED,
    this.customSanskritTextColor = 0xFF339933,
    this.enableBasicAdjust = true,
    this.enableBasicDisplay = true,
  });

  AppSettings copyWith({
    SearchMode? headwordSearchMode,
    SearchMode? definitionSearchMode,
    String? inputTranslit,
    String? outputTranslit,
    bool? showAccent,
    bool? highlightEnabled,
    int? maxResults,
    List<String>? activeDictCodes,
    List<String>? dictOrder,
    AppThemeMode? themeMode,
    int? customPrimaryColor,
    int? customBackgroundColor,
    int? customHeadwordColor,
    int? customSanskritTextColor,
    bool? enableBasicAdjust,
    bool? enableBasicDisplay,
  }) {
    return AppSettings(
      headwordSearchMode: headwordSearchMode ?? this.headwordSearchMode,
      definitionSearchMode: definitionSearchMode ?? this.definitionSearchMode,
      inputTranslit: inputTranslit ?? this.inputTranslit,
      outputTranslit: outputTranslit ?? this.outputTranslit,
      showAccent: showAccent ?? this.showAccent,
      highlightEnabled: highlightEnabled ?? this.highlightEnabled,
      maxResults: maxResults ?? this.maxResults,
      activeDictCodes: activeDictCodes ?? this.activeDictCodes,
      dictOrder: dictOrder ?? this.dictOrder,
      themeMode: themeMode ?? this.themeMode,
      customPrimaryColor: customPrimaryColor ?? this.customPrimaryColor,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      customHeadwordColor: customHeadwordColor ?? this.customHeadwordColor,
      customSanskritTextColor:
          customSanskritTextColor ?? this.customSanskritTextColor,
      enableBasicAdjust: enableBasicAdjust ?? this.enableBasicAdjust,
      enableBasicDisplay: enableBasicDisplay ?? this.enableBasicDisplay,
    );
  }

  Color get customPrimary => Color(customPrimaryColor);
  Color get customBackground => Color(customBackgroundColor);
  Color get customHeadword => Color(customHeadwordColor);
  Color get customSanskritText => Color(customSanskritTextColor);
}
