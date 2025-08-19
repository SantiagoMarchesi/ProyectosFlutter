import 'package:flutter/material.dart';

/// Controla el tema claro/oscuro de toda la app.
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light; // Cambia a ThemeMode.system si prefieres

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

/// Maneja el índice de la pestaña actual (útil para BottomNavigationBar).
class SelectedPageNotifier extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void setIndex(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }
}

/// Preferencias simples de usuario (opcional).
/// Úsalo si quieres compartir el estado de Ajustes en toda la app.
class SettingsNotifier extends ChangeNotifier {
  String _menuItem = 'Opción 1';
  bool _notifications = true;
  double _volume = 0.5;

  String get menuItem => _menuItem;
  bool get notifications => _notifications;
  double get volume => _volume;

  void setMenuItem(String value) {
    if (_menuItem == value) return;
    _menuItem = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    if (_notifications == value) return;
    _notifications = value;
    notifyListeners();
  }

  void setVolume(double value) {
    if (_volume == value) return;
    _volume = value.clamp(0.0, 1.0);
    notifyListeners();
  }
}


