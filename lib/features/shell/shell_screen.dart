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

  final Map<ShortcutActivator, Intent> _shortcuts = {
    const SingleActivator(LogicalKeyboardKey.keyB, control: true): 
        const _ToggleSidebarIntent(),
    const SingleActivator(LogicalKeyboardKey.keyT, control: true, shift: true): 
        const _ToggleThemeIntent(),
  };

  late final Map<Type, Action<Intent>> _actions = {
    _ToggleSidebarIntent: CallbackAction<_ToggleSidebarIntent>(
      onInvoke: (_) => setState(() => _isSidebarVisible = !_isSidebarVisible),
    ),
    _ToggleThemeIntent: CallbackAction<_ToggleThemeIntent>(
      onInvoke: (_) => context.read<ThemeProvider>().toggleTheme(),
    ),
  };
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _actions,
        child: Focus(
          autofocus: true,
          child: Scaffold(
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
          ),
        ),
      ),
    );
  }

  Widget _buildEditorArea() {
    return const EditorScreen();
  }
}

class _ToggleSidebarIntent extends Intent {
  const _ToggleSidebarIntent();
}

class _ToggleThemeIntent extends Intent {
  const _ToggleThemeIntent();
}

