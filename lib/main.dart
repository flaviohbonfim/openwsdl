import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/theme/theme_provider.dart';
import 'features/editor/controller/tab_manager.dart';
import 'features/wsdl/wsdl_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar preferências (tema, etc.)
  await ThemeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TabManager()..initIfEmpty()),
        ChangeNotifierProvider(create: (_) => WsdlProvider()),
      ],
      child: const SoapLiteApp(),
    ),
  );
}
