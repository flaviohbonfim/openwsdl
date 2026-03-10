import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de temas da aplicação
/// Gerencia a preferência entre tema claro e escuro
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  
  static ThemeMode _savedThemeMode = ThemeMode.system;
  
  ThemeMode _themeMode = _savedThemeMode;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _savedThemeMode = ThemeMode.values[themeIndex];
  }
  
  ThemeProvider() {
    _themeMode = _savedThemeMode;
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
    
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
    
    notifyListeners();
  }
  
  // Tema Claro (Alto Contraste)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: Colors.white,
        primary: Colors.blue[900]!,
        secondary: Colors.blue[700]!,
        tertiary: Colors.blue[300]!,
        error: Colors.red[700]!,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.grey[100],
        selectedIconTheme: IconThemeData(color: Colors.blue[900], size: 24),
        unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 24),
        selectedLabelTextStyle: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
      ),
      dividerColor: Colors.grey[300],
    );
  }
  
  // Tema Escuro (Alto Contraste)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: Color(0xFF1E1E1E), // VS Code dark
        primary: Colors.blue[400]!,
        secondary: Colors.blue[300]!,
        tertiary: Colors.blue[700]!,
        error: Colors.red[400]!,
      ),
      scaffoldBackgroundColor: Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFF252526),
        selectedIconTheme: const IconThemeData(color: Colors.blue, size: 24),
        unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 24),
        selectedLabelTextStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
      ),
      dividerColor: Colors.grey[800],
    );
  }
}
