import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  bool _isDarkMode = false;

  ThemeProvider(this._storageService) {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  void _loadTheme() {
    _isDarkMode = _storageService.settingsBox.get(
      'isDarkMode',
      defaultValue: false,
    );
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    _storageService.settingsBox.put('isDarkMode', isDark);
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed in the future
    super.dispose();
  }
}
