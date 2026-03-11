import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../wsdl/widgets/wsdl_explorer.dart';
import '../wsdl/widgets/import_wsdl_dialog.dart';
import '../collections/widgets/collection_tree_view.dart';
import '../collections/controller/collection_provider.dart';
import '../history/widgets/history_list_panel.dart';
import '../import_export/services/postman_importer.dart';

/// Barra lateral dinâmica
/// Exibe conteúdo baseado no índice selecionado no NavigationRail
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final double width;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header do Sidebar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[200],
            child: Row(
              children: [
                Text(
                  _getTitle().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (selectedIndex == 0) // WSDL
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'Importar WSDL',
                    onPressed: () => _showImportDialog(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (selectedIndex == 1) // Coleções
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.file_upload_outlined, size: 18),
                        tooltip: 'Importar Coleção Postman',
                        onPressed: () => _importPostman(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        tooltip: 'Nova Coleção',
                        onPressed: () => _showAddCollectionDialog(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Conteúdo do Sidebar
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (selectedIndex) {
      case 0: return 'Explorador WSDL';
      case 1: return 'Coleções';
      case 2: return 'Histórico';
      default: return '';
    }
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0: return const WsdlExplorer();
      case 1: return const CollectionTreeView();
      case 2: return const HistoryListPanel();
      default: return const SizedBox.shrink();
    }
  }

  void _importPostman(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final collection = PostmanImporter.import(content);
        
        if (context.mounted) {
          context.read<CollectionProvider>().addCollectionFromModel(collection);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coleção "${collection.name}" importada!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar: $e')),
        );
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ImportWsdlDialog(),
    );
  }

  void _showAddCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Coleção'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da Coleção'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CollectionProvider>().addCollection(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}
