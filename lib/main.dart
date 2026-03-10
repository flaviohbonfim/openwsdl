import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/theme/theme_provider.dart';
import 'features/editor/controller/tab_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar preferências (tema, etc.)
  await ThemeProvider.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TabManager()..initIfEmpty()),
      ],
      child: const SoapLiteApp(),
    ),
  );
}
