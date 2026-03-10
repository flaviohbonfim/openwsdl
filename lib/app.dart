import 'package:flutter/material.dart';
import 'config/theme/theme_provider.dart';
import 'features/shell/shell_screen.dart';

class SoapLiteApp extends StatefulWidget {
  const SoapLiteApp({super.key});

  @override
  State<SoapLiteApp> createState() => _SoapLiteAppState();
}

class _SoapLiteAppState extends State<SoapLiteApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOAP-Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: ThemeMode.system,
      home: const ShellScreen(),
    );
  }
}
