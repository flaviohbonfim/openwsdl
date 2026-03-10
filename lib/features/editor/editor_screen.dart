import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/tab_manager.dart';
import 'controller/tab_editor_state.dart';
import 'widgets/app_tab_bar.dart';
import 'widgets/monaco_editor.dart';
import 'widgets/editor_toolbar.dart';
import 'package:flutter/services.dart';

/// Tela do editor de código
/// Responsável por gerenciar abas e exibição do Monaco Editor
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey<MonacoEditorWidgetState> _editorKey = GlobalKey<MonacoEditorWidgetState>();

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManager>();
    
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
            tabManager.addTab(),
        const SingleActivator(LogicalKeyboardKey.keyW, control: true): () {
          if (tabManager.activeTabIndex != -1) {
            tabManager.closeTab(tabManager.activeTabIndex);
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyF, shift: true, alt: true):
            () => _editorKey.currentState?.format(),
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            // Barra de Abas
            const AppTabBar(),
            
            // Barra de Ferramentas
            EditorToolbar(
              onFormat: () => _editorKey.currentState?.format(),
              onCopy: () {
                final content = tabManager.activeTab?.content ?? '';
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copiado para o clipboard'), duration: Duration(seconds: 1)),
                );
              },
              onPaste: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  _editorKey.currentState?.setValue(data!.text!);
                }
              },
            ),
            
            // Área do Editor
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: tabManager.activeTab == null
                    ? const Center(
                        child: Text(
                          'Nenhuma aba aberta.\nAbra um arquivo ou crie uma nova requisição.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : MonacoEditorWidget(
                        key: _editorKey,
                        tab: tabManager.activeTab!,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
