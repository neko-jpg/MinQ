import 'dart:async';

import 'package:minq/data/services/local_preferences_service.dart';

class ContactLinkRepository {
  ContactLinkRepository(this._preferences);

  final LocalPreferencesService _preferences;
  Map<int, String>? _cache;

  Future<void> _ensureCache() async {
    if (_cache != null) return;
    final loaded = await _preferences.loadQuestContactLinks();
    _cache = Map<int, String>.from(loaded);
  }

  Future<Map<int, String>> getAllLinks() async {
    await _ensureCache();
    return Map<int, String>.unmodifiable(_cache!);
  }

  Future<String?> getLink(int questId) async {
    await _ensureCache();
    return _cache![questId];
  }

  Future<void> setLink(int questId, String? link) async {
    await _ensureCache();
    final sanitized = link?.trim();
    if (sanitized == null || sanitized.isEmpty) {
      _cache!.remove(questId);
    } else {
      _cache![questId] = sanitized;
    }
    await _preferences.saveQuestContactLinks(_cache!);
  }

  Future<void> removeLink(int questId) async {
    await setLink(questId, null);
  }
}
