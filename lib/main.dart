import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar preferências (tema, etc.)
  // await ThemeProvider.initialize();
  
  runApp(const SoapLiteApp());
}
