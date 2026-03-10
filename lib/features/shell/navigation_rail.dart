import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/theme_provider.dart';

/// Barra de navegação lateral estilo VS Code
/// Contém ícones de acesso rápido para diferentes funcionalidades
class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  
  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: isDark 
          ? const Color(0xFF252526) 
          : Colors.grey[100],
      leading: Column(
        children: [
          const SizedBox(height: 12),
          // Logo/Ícone do App
          Icon(
            Icons.code,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
        ],
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão de Toggle de Tema
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode ? 'Tema Claro' : 'Tema Escuro',
              ),
              const SizedBox(height: 8),
              // Botão de Configurações
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Implementar configurações
                },
                tooltip: 'Configurações',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.folder_open),
          label: Text('Explorador'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.search),
          label: Text('Buscar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.extension),
          label: Text('Extensões'),
        ),
      ],
    );
  }
}
