import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/theme/theme_provider.dart';
import 'features/editor/controller/tab_manager.dart';
import 'features/wsdl/wsdl_provider.dart';
import 'features/environment/controller/environment_provider.dart';
import 'features/collections/controller/collection_provider.dart';
import 'features/history/controller/history_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviços de persistência
  final storage = StorageService();
  await storage.init();

  // Inicializar preferências (tema, etc.)
  await ThemeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EnvironmentProvider()),
        ChangeNotifierProvider(create: (_) => TabManager()..initIfEmpty()),
        ChangeNotifierProvider(create: (_) => WsdlProvider()),
        ChangeNotifierProvider(
            create: (_) => CollectionProvider()..loadCollections()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
      ],
      child: const SoapLiteApp(),
    ),
  );
}
