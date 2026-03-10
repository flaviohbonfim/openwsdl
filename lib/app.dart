import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/theme_provider.dart';
import 'features/shell/shell_screen.dart';

class SoapLiteApp extends StatelessWidget {
  const SoapLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SOAP-Lite',
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const ShellScreen(),
        );
      },
    );
  }
}
