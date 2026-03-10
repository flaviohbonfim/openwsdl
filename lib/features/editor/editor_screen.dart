import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/tab_manager.dart';
import 'controller/tab_editor_state.dart';
import 'widgets/app_tab_bar.dart';
import 'widgets/monaco_editor.dart';
import 'widgets/editor_toolbar.dart';
import '../environment/controller/environment_provider.dart';
import '../response/widgets/response_panel.dart';
import 'package:flutter/services.dart';

/// Tela do editor de código
/// Responsável por gerenciar abas e exibição do Monaco Editor
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey<MonacoEditorWidgetState> _editorKey =
      GlobalKey<MonacoEditorWidgetState>();
  double _responsePanelHeight = 250;
  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManager>();
    final activeTab = tabManager.activeTab;

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
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          final envProvider = context.read<EnvironmentProvider>();
          tabManager.executeSoapRequest(envProvider.getActiveVariables());
        },
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
                final content = activeTab?.content ?? '';
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Copiado para o clipboard'),
                      duration: Duration(seconds: 1)),
                );
              },
              onPaste: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  _editorKey.currentState?.setValue(data!.text!);
                }
              },
              onSend: () {
                final envProvider = context.read<EnvironmentProvider>();
                tabManager.executeSoapRequest(envProvider.getActiveVariables());
              },
              onToggleLayout: tabManager.toggleLayout,
              isExecuting: activeTab?.isExecuting ?? false,
              isVerticalLayout: tabManager.isVerticalSplit,
            ),

            // Área do Editor e Painel de Resposta
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Flex(
                  direction: tabManager.isVerticalSplit
                      ? Axis.horizontal
                      : Axis.vertical,
                  children: [
                    // Área de Requisição
                    Expanded(
                      child: Column(
                        children: [
                          // Seletor de sub-abas da requisição
                          if (activeTab != null)
                            Container(
                              height: 30,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.1))),
                              ),
                              child: TabBar(
                                isScrollable: true,
                                dividerColor: Colors.transparent,
                                indicatorWeight: 1,
                                labelStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                                unselectedLabelStyle:
                                    const TextStyle(fontSize: 11),
                                tabs: const [
                                  Tab(text: 'CORPO'),
                                  Tab(text: 'HEADERS'),
                                ],
                              ),
                            ),

                          // Conteúdo da Requisição (Corpo ou Headers)
                          Expanded(
                            child: Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: activeTab == null
                                  ? const Center(
                                      child: Text(
                                        'Nenhuma aba aberta.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : TabBarView(
                                      children: [
                                        MonacoEditorWidget(
                                          key: _editorKey,
                                          tab: activeTab,
                                        ),
                                        _RequestHeadersEditor(tab: activeTab),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divisor (Splitter)
                    if (activeTab != null) _buildSplitter(tabManager),

                    // Painel de Resposta
                    if (activeTab != null)
                      SizedBox(
                        width: tabManager.isVerticalSplit
                            ? _responsePanelHeight
                            : double.infinity,
                        height: tabManager.isVerticalSplit
                            ? double.infinity
                            : _responsePanelHeight,
                        child: const ResponsePanel(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitter(TabManager tabManager) {
    final isVertical = tabManager.isVerticalSplit;
    return MouseRegion(
      cursor: isVertical
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            if (isVertical) {
              _responsePanelHeight = (_responsePanelHeight - details.delta.dx)
                  .clamp(100.0, 800.0);
            } else {
              _responsePanelHeight = (_responsePanelHeight - details.delta.dy)
                  .clamp(100.0, 600.0);
            }
          });
        },
        onPanStart: (_) => setState(() => _isResizing = true),
        onPanEnd: (_) => setState(() => _isResizing = false),
        child: Container(
          width: isVertical ? 4 : double.infinity,
          height: isVertical ? double.infinity : 4,
          color: _isResizing
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor.withOpacity(0.1),
          child: Center(
            child: Container(
              width: isVertical ? 1 : double.infinity,
              height: isVertical ? double.infinity : 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestHeadersEditor extends StatelessWidget {
  final TabEditorState tab;

  const _RequestHeadersEditor({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Headers da Requisição',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          // Lista simples de headers (Para Fase 4.5)
          Expanded(
            child: ListView(
              children: [
                _HeaderRow(
                  name: 'Content-Type',
                  value: 'text/xml; charset=utf-8',
                  isReadOnly: true,
                ),
                if (tab.soapAction != null)
                  _HeaderRow(
                    name: 'SOAPAction',
                    value: tab.soapAction!,
                    isReadOnly: true,
                  ),
                // Aqui poderiam vir headers customizados
                ...tab.customHeaders.entries.map((e) => _HeaderRow(
                      name: e.key,
                      value: e.value,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String name;
  final String value;
  final bool isReadOnly;

  const _HeaderRow({
    required this.name,
    required this.value,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(name, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(value, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isReadOnly ? Icons.lock_outline : Icons.close,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
