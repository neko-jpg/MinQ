import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/settings/settings_search_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/settings/settings_category.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Settings Search', () {
    late List<SettingsCategory> testCategories;

    setUp(() {
      testCategories = [
        SettingsCategory(
          id: 'appearance',
          title: 'Appearance',
          icon: Icons.palette,
          items: [
            SettingsItem(
              id: 'theme_mode',
              title: 'Theme Mode',
              subtitle: 'Light or dark theme',
              type: SettingsItemType.selection,
              searchKeywords: ['theme', 'dark', 'light'],
            ),
            SettingsItem(
              id: 'accent_color',
              title: 'Accent Color',
              subtitle: 'App accent color',
              type: SettingsItemType.colorPicker,
              searchKeywords: ['color', 'accent'],
            ),
          ],
        ),
        SettingsCategory(
          id: 'notifications',
          title: 'Notifications',
          icon: Icons.notifications,
          items: [
            SettingsItem(
              id: 'notifications_enabled',
              title: 'Enable Notifications',
              subtitle: 'Receive push notifications',
              type: SettingsItemType.toggle,
              searchKeywords: ['notifications', 'push'],
            ),
          ],
        ),
      ];
    });

    test('should find items by title', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final service = SettingsSearchService(storage);
      final results = service.searchSettings(testCategories, 'theme');

      expect(results.length, 1);
      expect(results.first.item.title, 'Theme Mode');
    });

    test('should find items by subtitle', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final service = SettingsSearchService(storage);
      final results = service.searchSettings(testCategories, 'push');

      expect(results.length, 1);
      expect(results.first.item.title, 'Enable Notifications');
    });

    test('should find items by keywords', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final service = SettingsSearchService(storage);
      final results = service.searchSettings(testCategories, 'dark');

      expect(results.length, 1);
      expect(results.first.item.title, 'Theme Mode');
    });

    test('should return empty results for no matches', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final service = SettingsSearchService(storage);
      final results = service.searchSettings(testCategories, 'nonexistent');

      expect(results.length, 0);
    });

    test('should calculate relevance scores correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final service = SettingsSearchService(storage);
      final results = service.searchSettings(testCategories, 'color');

      expect(results.length, 1);
      expect(results.first.relevanceScore, greaterThan(0));
    });

    test('should return popular search suggestions', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final service = SettingsSearchService(storage);
      final suggestions = service.getSearchSuggestions();

      expect(suggestions.isNotEmpty, true);
      expect(suggestions.contains('テーマ'), true);
    });
  });
}

