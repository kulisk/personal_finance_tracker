// Theme state backed by Hive settings.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../services/hive_service.dart';

// Stores the user-selected theme seed color.
class ThemeStore extends ChangeNotifier {
  ThemeStore() : _settingsBox = HiveService.settingsBox {
    // Restore the saved color or fall back to a default.
    final stored = _settingsBox.get(_seedColorKey);
    _seedColor =
        stored != null ? Color(stored) : const Color.fromARGB(255, 7, 184, 22);
  }

  static const String _seedColorKey = 'theme_seed_color';

  final Box<int> _settingsBox;
  late Color _seedColor;

  // Current seed color for theming.
  Color get seedColor => _seedColor;

  // Updates the seed color and persists it.
  Future<void> setSeedColor(Color color) async {
    if (color.value == _seedColor.value) {
      return;
    }

    _seedColor = color;
    await _settingsBox.put(_seedColorKey, color.value);
    notifyListeners();
  }
}
