import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/theme_provider.dart';
import 'features/shell/shell_screen.dart';

class OpenWsdlApp extends StatelessWidget {
  const OpenWsdlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'OpenWsdl',
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
