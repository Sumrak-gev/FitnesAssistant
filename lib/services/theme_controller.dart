import 'package:flutter/material.dart';
import '../data/fitness_repository.dart';

enum AppPalette { israel, mint }

class ThemeController extends ChangeNotifier {
  ThemeController(this._records);

  final FitnessRepository _records;
  ThemeMode mode = ThemeMode.system;
  AppPalette palette = AppPalette.israel;

  Future<void> load() async {
    final saved = await _records.setting('themeMode');
    mode =
        ThemeMode.values.where((value) => value.name == saved).firstOrNull ??
        ThemeMode.system;
    final savedPalette = await _records.setting('themePalette');
    palette =
        AppPalette.values
            .where((value) => value.name == savedPalette)
            .firstOrNull ??
        AppPalette.israel;
    notifyListeners();
  }

  Future<void> select(ThemeMode value) async {
    await _records.setSetting('themeMode', value.name);
    mode = value;
    notifyListeners();
  }

  Future<void> selectPalette(AppPalette value) async {
    await _records.setSetting('themePalette', value.name);
    palette = value;
    notifyListeners();
  }
}
