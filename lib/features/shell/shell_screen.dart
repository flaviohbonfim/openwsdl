import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_rail.dart';
import 'sidebar.dart';
import '../../core/widgets/status_bar.dart';
import '../../config/theme/theme_provider.dart';
import '../editor/editor_screen.dart';

/// Tela principal da aplicação (Shell)
/// Layout estilo VS Code com:
/// - NavigationRail lateral esquerda
/// - ExplorerSidebar redimensionável
/// - Área central de editor
/// - StatusBar inferior
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedNavIndex = 0;
  bool _isSidebarVisible = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail
          AppNavigationRail(
            selectedIndex: _selectedNavIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedNavIndex = index;
                
                // Mostrar sidebar apenas para explorador
                if (index == 0) {
                  _isSidebarVisible = true;
                } else {
                  _isSidebarVisible = false;
                }
              });
            },
          ),
          
          // Explorer Sidebar (visível apenas no índice 0)
          ExplorerSidebar(isVisible: _isSidebarVisible),
          
          // Área Principal (Editor + Status Bar)
          Expanded(
            child: Column(
              children: [
                // Área do Editor
                Expanded(
                  child: _buildEditorArea(),
                ),
                
                // Barra de Status
                const StatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditorArea() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'SOAP-Lite',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Importe um WSDL para começar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
