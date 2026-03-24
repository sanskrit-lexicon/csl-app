import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cologne_sanskrit_lexicon/features/home/home_screen.dart';
import 'package:cologne_sanskrit_lexicon/core/transliteration_service.dart';
import 'package:cologne_sanskrit_lexicon/models/app_settings.dart';
import 'package:cologne_sanskrit_lexicon/providers/settings_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Cologne Sanskrit Lexicon',
      debugShowCheckedModeBanner: false,
      theme: settings.themeMode == AppThemeMode.cologne
          ? _buildCologneTheme()
          : ThemeData(
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
