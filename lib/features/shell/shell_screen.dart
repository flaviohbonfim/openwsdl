import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isSidebarVisible = false;
  double _sidebarWidth = 250;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeys);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeys);
    super.dispose();
  }

  bool _handleGlobalKeys(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isControlPressed = HardwareKeyboard.instance.isControlPressed;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
      final isAltPressed = HardwareKeyboard.instance.isAltPressed;

      // Ctrl + B (Toggle Sidebar)
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyB) {
        setState(() => _isSidebarVisible = !_isSidebarVisible);
        return true;
      }

      // Ctrl + Shift + T (Toggle Theme) - Corrigi o atalho de acordo com o plano original
      if (isControlPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyT) {
        context.read<ThemeProvider>().toggleTheme();
        return true;
      }
      
      // Atalhos do Editor delegados via Actions para o EditorScreen
      // Ctrl + S
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        Actions.maybeInvoke(context, const SaveIntent());
        return true;
      }

      // Ctrl + Enter
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.enter) {
        Actions.maybeInvoke(context, const ExecuteRequestIntent());
        return true;
      }

      // Ctrl + T (Nova Aba)
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyT && !isShiftPressed) {
        Actions.maybeInvoke(context, const NewTabIntent());
        return true;
      }

      // Ctrl + W (Fechar Aba)
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyW) {
        Actions.maybeInvoke(context, const CloseTabIntent());
        return true;
      }

      // Shift + Alt + F (Formatar)
      if (isShiftPressed && isAltPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        Actions.maybeInvoke(context, const FormatIntent());
        return true;
      }
    }
    return false;
  }
  
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
                if (_selectedNavIndex == index) {
                  _isSidebarVisible = !_isSidebarVisible;
                } else {
                  _selectedNavIndex = index;
                  _isSidebarVisible = true;
                }
              });
            },
          ),
          
          // Sidebar redimensionável
          if (_isSidebarVisible) ...[
            Sidebar(
              selectedIndex: _selectedNavIndex,
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


