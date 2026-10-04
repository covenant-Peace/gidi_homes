import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_search.dart';

/// Persists saved searches locally (per device).
class SavedSearchRepository {
  static const _key = 'gidi_saved_searches';

  Future<List<SavedSearch>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(SavedSearch.fromMap).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<SavedSearch> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(searches.map((s) => s.toMap()).toList()));
  }
}
