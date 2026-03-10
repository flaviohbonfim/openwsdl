import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../editor/controller/tab_manager.dart';
import '../../../core/utils/xml_utils.dart';
import 'response_headers_view.dart';
import 'package:flutter_monaco/flutter_monaco.dart';
import '../../../config/theme/theme_provider.dart';

class ResponsePanel extends StatefulWidget {
  const ResponsePanel({super.key});

  @override
  State<ResponsePanel> createState() => _ResponsePanelState();
}

class _ResponsePanelState extends State<ResponsePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManager>();
    final activeTab = tabManager.activeTab;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (activeTab == null) return const SizedBox.shrink();

    if (activeTab.isExecuting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Executando requisição...'),
          ],
        ),
      );
    }

    final response = activeTab.lastResponse;

    if (response == null) {
      return const Center(
        child: Text(
          'Nenhuma resposta para esta aba.\nClique em "Enviar" para executar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Header do Painel (Abas + Status)
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  tabs: const [
                    Tab(text: 'Corpo'),
                    Tab(text: 'Headers'),
                    Tab(text: 'Raw'),
                  ],
                ),
              ),
              // Status, Tempo, etc.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatusBadge(statusCode: response.statusCode),
                    const SizedBox(width: 12),
                    Text(
                      '${response.executionTime.inMilliseconds}ms',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Conteúdo
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Corpo (Pretty Print)
              _ResponseBodyView(
                content: XmlUtils.prettyPrint(response.body),
                language: 'xml',
              ),
              // Headers
              ResponseHeadersView(headers: response.headers),
              // Raw
              _ResponseBodyView(
                content: response.body,
                language: 'plaintext',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int statusCode;

  const _StatusBadge({required this.statusCode});

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = statusCode >= 200 && statusCode < 300;
    final Color color = isSuccess ? Colors.green : Colors.red;

    if (statusCode == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        statusCode.toString(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ResponseBodyView extends StatelessWidget {
  final String content;
  final String language;

  const _ResponseBodyView({required this.content, required this.language});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const Center(child: Text('Corpo vazio.'));
    }

    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final monacoTheme = isDark ? MonacoTheme.vsDark : MonacoTheme.vs;
    final monacoLanguage =
        language == 'xml' ? MonacoLanguage.xml : MonacoLanguage.plaintext;

    return MonacoEditor(
      initialValue: content,
      options: EditorOptions(
        theme: monacoTheme,
        language: monacoLanguage,
        readOnly: true,
      ),
    );
  }
}
