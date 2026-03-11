import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'navigation_rail.dart';
import 'sidebar.dart';
import '../../core/widgets/status_bar.dart';
import '../../config/theme/theme_provider.dart';
import '../editor/editor_screen.dart';

/// Tela principal da aplicação (Shell)
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  /// Permite acesso ao state para disparar toggles de fora
  static final GlobalKey<ShellScreenState> globalKey = GlobalKey<ShellScreenState>();
  
  @override
  State<ShellScreen> createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  final GlobalKey<EditorScreenState> _editorScreenKey = GlobalKey<EditorScreenState>();
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
    if (event is! KeyDownEvent) return false;

    final isControl = HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    // Atalhos que funcionam sempre
    
    // Ctrl + B (Toggle Sidebar)
    if (isControl && event.logicalKey == LogicalKeyboardKey.keyB) {
      toggleSidebar();
      return true;
    }

    // Ctrl + Shift + T (Toggle Theme)
    if (isControl && isShift && event.logicalKey == LogicalKeyboardKey.keyT) {
      context.read<ThemeProvider>().toggleTheme();
      return true;
    }
    
    final editor = _editorScreenKey.currentState;
    if (editor == null) return false;

    // Ctrl + S (Salvar)
    if (isControl && event.logicalKey == LogicalKeyboardKey.keyS) {
      editor.save();
      return true;
    }

    // Ctrl + Enter (Executar)
    if (isControl && event.logicalKey == LogicalKeyboardKey.enter) {
      editor.executeRequest();
      return true;
    }

    // Ctrl + T (Nova Aba) - Só se não for Shift+T
    if (isControl && event.logicalKey == LogicalKeyboardKey.keyT && !isShift) {
      editor.newTab();
      return true;
    }

    // Ctrl + W (Fechar Aba)
    if (isControl && event.logicalKey == LogicalKeyboardKey.keyW) {
      editor.closeTab();
      return true;
    }

    // Shift + Alt + F (Formatar)
    if (isShift && isAlt && event.logicalKey == LogicalKeyboardKey.keyF) {
      editor.format();
      return true;
    }

    return false;
  }
  
  void toggleSidebar() {
    setState(() => _isSidebarVisible = !_isSidebarVisible);
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      // Este Focus permite que o Flutter receba os eventos de teclado 
      // mesmo quando o Monaco (PlatformView) está "ativo", 
      // mas sem roubar o foco de digitação.
      autofocus: true,
      debugLabel: 'ShellGlobalFocus',
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
                    child: EditorScreen(key: _editorScreenKey),
                  ),
                  
                  // Barra de Status
                  const StatusBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
