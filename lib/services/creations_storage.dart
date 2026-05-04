import 'package:shared_preferences/shared_preferences.dart';

/// Persists a list of generated image URLs locally
class CreationsStorage {
  static const _key = 'my_creations';

  /// Save a new image URL to the list
  static Future<void> saveCreation(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    // Avoid duplicates, add to front so newest appears first
    if (!list.contains(imageUrl)) {
      list.insert(0, imageUrl);
    }
    await prefs.setStringList(_key, list);
    print("[CreationsStorage] Saved. Total creations: ${list.length}");
  }

  /// Load all saved image URLs
  static Future<List<String>> loadCreations() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    print("[CreationsStorage] Loaded ${list.length} creations");
    return list;
  }

  /// Delete a specific image URL from the list
  static Future<void> deleteCreation(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(imageUrl);
    await prefs.setStringList(_key, list);
  }

  /// Clear all saved creations
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
