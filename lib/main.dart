import 'dart:async';
import 'package:flutter/foundation.dart';
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

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 7.1: Otimizar o processo de inicialização - Inicialização em paralelo
    final initFutures = [
      StorageService().init(),
      ThemeProvider.initialize(),
    ];

    await Future.wait(initFutures);

    // Configurar tratamento de erros do Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Aqui poderíamos enviar para um serviço de log/crashlytics
      if (kDebugMode) {
        print('Flutter Error: ${details.exception}');
      }
    };

    // Erros de plataforma/assíncronos
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        print('Platform Error: $error');
      }
      return true;
    };

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
        child: const OpenWsdlApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) {
      print('Uncaught Zone Error: $error');
    }
  });
}

