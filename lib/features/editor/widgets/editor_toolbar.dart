import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/tab_manager.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback? onFormat;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;

  const EditorToolbar({
    super.key,
    this.onFormat,
    this.onCopy,
    this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _ToolbarButton(
            icon: Icons.format_align_left_outlined,
            tooltip: 'Formatar XML (Alt+Shift+F)',
            onPressed: onFormat,
          ),
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
          _ToolbarButton(
            icon: Icons.copy_all_outlined,
            tooltip: 'Copiar Tudo',
            onPressed: onCopy,
          ),
          _ToolbarButton(
            icon: Icons.paste_outlined,
            tooltip: 'Colar',
            onPressed: onPaste,
          ),
          const Spacer(),
          // Placeholder para o botão de "Enviar" que virá na Fase 4
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Executar Requisição (Fase 4)')),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Enviar', style: TextStyle(fontSize: 12)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 16,
      visualDensity: VisualDensity.compact,
      color: Theme.of(context).hintColor,
    );
  }
}
