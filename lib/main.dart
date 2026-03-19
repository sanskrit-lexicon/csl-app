import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanskrit_lexicon/features/home/home_screen.dart';
import 'package:sanskrit_lexicon/core/transliteration_service.dart';
import 'package:sanskrit_lexicon/models/app_settings.dart';
import 'package:sanskrit_lexicon/providers/settings_provider.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Cologne Sanskrit Lexicon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // Saddle brown root color
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settings.themeMode.toThemeMode,
      home: const HomeScreen(),
    );
  }
}
