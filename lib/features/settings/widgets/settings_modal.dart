import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../history/controller/history_provider.dart';
import 'shortcut_details_modal.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configurações',
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
                  ListTile(
                    leading: const Icon(Icons.keyboard),
                    title: const Text('Atalhos de Teclado'),
                    subtitle: const Text('Visualizar e customizar atalhos'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ShortcutDetailsModal(),
                      );
                    },
                  ),
                  const Divider(),
                  _buildSection(context, 'Dados e Armazenamento'),
                  ListTile(
                    title: const Text('Limpar Histórico'),
                    subtitle: const Text('Apagar todas as requisições recentes'),
                    trailing: TextButton(
                      onPressed: () => _confirmClearHistory(context),
                      child: const Text('LIMPAR', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  ListTile(
                    title: const Text('Limpar Coleções'),
                    subtitle: const Text('Remover todas as coleções do app'),
                    trailing: TextButton(
                      onPressed: () => _confirmClearCollections(context),
                      child: const Text('LIMPAR ALL', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const Divider(),
                  _buildSection(context, 'Projeto Open Source'),
                  const ListTile(
                    title: Text('Nome do Projeto'),
                    trailing: Text('OpenWsdl'),
                  ),
                  const ListTile(
                    title: Text('Versão'),
                    trailing: Text('1.0.0'),
                  ),
                  const ListTile(
                    title: Text('Licença'),
                    trailing: Text('MIT'),
                  ),
                  const ListTile(
                    title: Text('Comunidade'),
                    trailing: Text('openwsdl.io'),
                  ),
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

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text('LIMPAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmClearCollections(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Coleções?'),
        content: const Text('Todas as suas coleções salvas serão removidas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              // TODO: Implement clearCollections in CollectionProvider if needed
              // context.read<CollectionProvider>().clearCollections();
              Navigator.pop(context);
            },
            child: const Text('LIMPAR ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
