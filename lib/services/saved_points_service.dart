import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_point.dart';

class SavedPointsService {
  static const _key = 'saved_points';

  static Future<List<SavedPoint>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => SavedPoint.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> save(String name, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final point = SavedPoint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      lat: lat,
      lng: lng,
      savedAt: DateTime.now(),
    );
    raw.add(jsonEncode(point.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => (jsonDecode(e) as Map<String, dynamic>)['id'] == id);
    await prefs.setStringList(_key, raw);
  }
}