import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/history_provider.dart';
import '../models/history_model.dart';
import '../../editor/controller/tab_manager.dart';

class HistoryListPanel extends StatelessWidget {
  const HistoryListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final history = provider.history;

    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum histórico disponível.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () => provider.clearHistory(),
            icon: const Icon(Icons.delete_sweep, size: 16),
            label: const Text('Limpar Tudo', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 32),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];
              return _HistoryListItem(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final HistoryItem item;

  const _HistoryListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final isError = item.response.error != null || item.response.statusCode == 0;
    
    return ListTile(
      dense: true,
      title: Text(
        item.requestName,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.url,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              _StatusBadge(
                statusCode: item.response.statusCode,
                isError: isError,
              ),
              const SizedBox(width: 8),
              Text(
                '${item.response.executionTime.inMilliseconds}ms',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                _formatDate(item.timestamp),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        context.read<TabManager>().addTab(
          title: '${item.requestName} (Histórico)',
          content: item.body,
          endpoint: item.url,
          soapAction: item.soapAction,
          customHeaders: item.headers,
        );
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 16),
        onPressed: () => context.read<HistoryProvider>().deleteHistoryItem(item.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final int statusCode;
  final bool isError;

  const _StatusBadge({required this.statusCode, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusCode == 0 ? 'ERR' : statusCode.toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
