import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';

/// Single-key persistence of the whole app state via shared_preferences.
class StorageService {
  static const String dataKey = 'stakebook_data';
  static const String corruptKey = 'stakebook_data_corrupt';

  /// Never throws: returns empty state if data is missing or corrupt.
  Future<AppData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(dataKey);
      if (raw == null || raw.isEmpty) return AppData.empty;
      try {
        return AppData.parse(raw);
      } on FormatException catch (e) {
        debugPrint('Stakebook: corrupt data ignored ($e)');
        // Keep a copy so nothing is silently destroyed.
        await prefs.setString(corruptKey, raw);
        return AppData.empty;
      }
    } catch (e) {
      debugPrint('Stakebook: load failed ($e)');
      return AppData.empty;
    }
  }

  Future<bool> save(AppData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(dataKey, data.toJsonString());
    } catch (e) {
      debugPrint('Stakebook: save failed ($e)');
      return false;
    }
  }
}
