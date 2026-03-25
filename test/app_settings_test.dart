import 'package:flutter_test/flutter_test.dart';
import 'package:cologne_sanskrit_lexicon/models/app_settings.dart';

void main() {
  group('AppSettings Tests', () {
    test('default values include listMode as false', () {
      final settings = AppSettings();
      expect(settings.listMode, false);
    });

    test('listMode can be set via copyWith', () {
      final settings = AppSettings();
      final updated = settings.copyWith(listMode: true);
      expect(updated.listMode, true);
    });

    test('copyWith preserves listMode when not specified', () {
      final settings = AppSettings(listMode: true);
      final updated = settings.copyWith(maxResults: 50);
      expect(updated.listMode, true);
    });

    test('listMode defaults to false in constructor', () {
      final settings = AppSettings(
        headwordSearchMode: SearchMode.exact,
        maxResults: 200,
      );
      expect(settings.listMode, false);
    });
  });
}
