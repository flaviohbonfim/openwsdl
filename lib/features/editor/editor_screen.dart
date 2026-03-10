import 'package:flutter/material.dart';

/// Tela do editor de código
/// Responsável por gerenciar abas e exibição do Monaco Editor
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          // Barra de Abas
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              tabs: const [
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.description, size: 16),
                      SizedBox(width: 8),
                      Text('Sem Título'),
                      Icon(Icons.close, size: 14),
                    ],
                  ),
                ),
              ],
              isScrollable: true,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          // Área do Editor (placeholder)
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: Text(
                  'Editor Monaco será integrado aqui',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
