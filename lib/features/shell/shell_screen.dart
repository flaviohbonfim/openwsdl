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
  double _sidebarWidth = 250;
  bool _isResizing = false;
  
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
          if (_isSidebarVisible) ...[
            ExplorerSidebar(
              isVisible: _isSidebarVisible,
              width: _sidebarWidth,
            ),
            // Divisor redimensionável
            MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                onHorizontalDragStart: (details) {
                  setState(() => _isResizing = true);
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(150.0, 400.0);
                  });
                },
                onHorizontalDragEnd: (details) {
                  setState(() => _isResizing = false);
                },
                child: Container(
                  width: 4,
                  color: _isResizing 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.transparent,
                  child: Container(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
          ],
          
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
    return const EditorScreen();
  }
}
