import 'package:flutter/material.dart';

/// Represents a category of settings
class SettingsCategory {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<SettingsItem> items;
  final bool isAdvanced;

  const SettingsCategory({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.items,
    this.isAdvanced = false,
  });
}

/// Represents an individual settings item
class SettingsItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final SettingsItemType type;
  final dynamic value;
  final List<SettingsOption>? options;
  final VoidCallback? onTap;
  final ValueChanged<dynamic>? onChanged;
  final bool isEnabled;
  final bool isDangerous;
  final String? route;
  final List<String> searchKeywords;

  const SettingsItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    required this.type,
    this.value,
    this.options,
    this.onTap,
    this.onChanged,
    this.isEnabled = true,
    this.isDangerous = false,
    this.route,
    this.searchKeywords = const [],
  });

  /// Check if this item matches the search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();

    // Check title
    if (title.toLowerCase().contains(lowerQuery)) return true;

    // Check subtitle
    if (subtitle?.toLowerCase().contains(lowerQuery) == true) return true;

    // Check search keywords
    for (final keyword in searchKeywords) {
      if (keyword.toLowerCase().contains(lowerQuery)) return true;
    }

    return false;
  }
}

/// Types of settings items
enum SettingsItemType {
  toggle,
  selection,
  navigation,
  action,
  info,
  colorPicker,
  timePicker,
  slider,
}

/// Option for selection-type settings
class SettingsOption {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final dynamic value;

  const SettingsOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.value,
  });
}
