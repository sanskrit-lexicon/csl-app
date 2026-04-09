import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cologne_sanskrit_lexicon/features/home/home_screen.dart';
import 'package:cologne_sanskrit_lexicon/core/transliteration_service.dart';
import 'package:cologne_sanskrit_lexicon/models/app_settings.dart';
import 'package:cologne_sanskrit_lexicon/providers/settings_provider.dart';
// Conditional import: selects the right database factory for each platform.
// db_init_io.dart   → Android / iOS / macOS / Windows / Linux (uses sqflite / sqflite_common_ffi)
// db_init_web.dart  → Web / WASM (uses sqflite_common_ffi_web → IndexedDB)
import 'db_init_stub.dart'
    if (dart.library.io) 'db_init_io.dart'
    if (dart.library.js_interop) 'db_init_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the correct SQLite database factory for the current platform.
  // On native: sqflite default (mobile) or sqflite_common_ffi (desktop).
  // On web:    sqflite_common_ffi_web (IndexedDB / WASM).
  await initDatabaseFactory();

  // Initialize transliteration schemes
  TransliterationService.init();

  runApp(
    const ProviderScope(
      child: SanslexApp(),
    ),
  );
}

class SanslexApp extends ConsumerWidget {
  const SanslexApp({super.key});

  static const Color _cologneBlue = Color(0xFF36648B);
  static const Color _cologneLightBlue = Color(0xFFDBE4ED);

  ThemeData _buildCologneTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _cologneBlue,
        brightness: Brightness.light,
        primary: _cologneBlue,
        surface: _cologneLightBlue,
      ),
      scaffoldBackgroundColor: _cologneLightBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: _cologneBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _cologneBlue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: _cologneBlue,
        dividerColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _cologneBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        menuStyle: MenuStyle(
          elevation: WidgetStatePropertyAll(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _cologneBlue,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _cologneBlue,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _cologneBlue;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _cologneBlue.withAlpha(128);
          }
          return Colors.grey.shade300;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _cologneBlue;
            }
            return Colors.white;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return _cologneBlue;
          }),
          side: WidgetStateProperty.all(const BorderSide(color: _cologneBlue)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: _cologneBlue,
      ),
      dividerTheme: const DividerThemeData(
        color: _cologneBlue,
        thickness: 0.5,
      ),
    );
  }

  ThemeData _buildCustomTheme(AppSettings settings) {
    final primary = settings.customPrimary;
    final background = settings.customBackground;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: background,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        menuStyle: MenuStyle(
          elevation: WidgetStatePropertyAll(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withAlpha(128);
          }
          return Colors.grey.shade300;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }
            return Colors.white;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return primary;
          }),
          side: WidgetStateProperty.all(BorderSide(color: primary)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
      ),
      dividerTheme: DividerThemeData(
        color: primary,
        thickness: 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeData? theme;
    if (settings.themeMode == AppThemeMode.cologne) {
      theme = _buildCologneTheme();
    } else if (settings.themeMode == AppThemeMode.custom) {
      theme = _buildCustomTheme(settings);
    }

    return MaterialApp(
      title: 'Cologne Sanskrit Lexicon',
      debugShowCheckedModeBanner: false,
      theme: theme ??
          ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B4513),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            dropdownMenuTheme: const DropdownMenuThemeData(
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              menuStyle: MenuStyle(
                elevation: WidgetStatePropertyAll(4),
              ),
            ),
          ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF424242),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          menuStyle: MenuStyle(
            elevation: WidgetStatePropertyAll(4),
          ),
        ),
      ),
      themeMode: settings.themeMode.toThemeMode,
      home: const HomeScreen(),
    );
  }
}
