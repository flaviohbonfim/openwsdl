import 'package:flutter/material.dart';
import '../wsdl/widgets/wsdl_explorer.dart';
import '../wsdl/widgets/import_wsdl_dialog.dart';

/// Barra lateral de explorador de serviços
/// Exibe a árvore hierárquica: Projeto → Serviço → Binding → Operação
class ExplorerSidebar extends StatelessWidget {
  final bool isVisible;
  final double width;

  const ExplorerSidebar({
    super.key,
    required this.isVisible,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 400),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252526) : Colors.grey[100],
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header do Explorador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[200],
            child: Row(
              children: [
                const Text(
                  'EXPLORADOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: 'Importar WSDL',
                  onPressed: () => _showImportDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 18),
                  onPressed: () {
                    // Menu de opções do explorador
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Conteúdo do Explorador
          const Expanded(
            child: WsdlExplorer(),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ImportWsdlDialog(),
    );
  }
}
