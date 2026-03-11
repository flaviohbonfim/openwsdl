import 'package:flutter/material.dart';

class ShortcutDetailsModal extends StatelessWidget {
  const ShortcutDetailsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atalhos de Teclado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSection(context, 'Geral'),
                  _buildShortcutRow(context, 'Alternar Barra Lateral', 'Ctrl + B'),
                  _buildShortcutRow(context, 'Alternar Tema', 'Ctrl + Shift + T'),
                  const Divider(),
                  _buildSection(context, 'Editor'),
                  _buildShortcutRow(context, 'Nova Aba', 'Ctrl + T'),
                  _buildShortcutRow(context, 'Fechar Aba', 'Ctrl + W'),
                  _buildShortcutRow(context, 'Salvar Requisição', 'Ctrl + S'),
                  _buildShortcutRow(context, 'Executar Requisição', 'Ctrl + Enter'),
                  _buildShortcutRow(context, 'Formatar XML', 'Shift + Alt + F'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context, String label, String keys) {
    return ListTile(
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          keys,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
