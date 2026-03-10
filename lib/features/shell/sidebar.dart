import 'package:flutter/material.dart';

/// Barra lateral de explorador de serviços
/// Exibe a árvore hierárquica: Projeto → Serviço → Binding → Operação
class ExplorerSidebar extends StatelessWidget {
  final bool isVisible;
  
  const ExplorerSidebar({
    super.key,
    required this.isVisible,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 250,
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
          Expanded(
            child: _buildExplorerContent(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExplorerContent(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Botão de Importar WSDL
        ListTile(
          leading: const Icon(Icons.cloud_download, size: 18),
          title: const Text('Importar WSDL'),
          subtitle: const Text(
            'Carregar de arquivo ou URL',
            style: TextStyle(fontSize: 11),
          ),
          onTap: () {
            // TODO: Implementar importação de WSDL
          },
        ),
        const Divider(height: 1),
        
        // Seção de Coleções (vazia inicialmente)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'COLEÇÕES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        // Mensagem de estado vazio
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.folder_open,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhuma coleção',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Importe um WSDL para começar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
