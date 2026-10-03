import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's saved/favourited listing ids locally.
class FavoritesRepository {
  static const _key = 'gidi_favorites';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
