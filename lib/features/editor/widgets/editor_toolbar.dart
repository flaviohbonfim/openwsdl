import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/tab_manager.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback? onFormat;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onSend;
  final VoidCallback? onToggleLayout;
  final bool isExecuting;
  final bool isVerticalLayout;

  const EditorToolbar({
    super.key,
    this.onFormat,
    this.onCopy,
    this.onPaste,
    this.onSend,
    this.onToggleLayout,
    this.isExecuting = false,
    this.isVerticalLayout = true,
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
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
          _ToolbarButton(
            icon: isVerticalLayout
                ? Icons.horizontal_split_outlined
                : Icons.vertical_split_outlined,
            tooltip: isVerticalLayout
                ? 'Layout Horizontal (Resposta abaixo)'
                : 'Layout Vertical (Resposta ao lado)',
            onPressed: onToggleLayout,
          ),
          const Spacer(),
          // Botão de "Enviar" (Fase 4)
          SizedBox(
            height: 24,
            child: FilledButton.icon(
              onPressed: isExecuting ? null : onSend,
              icon: isExecuting
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow_rounded, size: 16),
              label: Text(isExecuting ? 'Enviando...' : 'Enviar',
                  style: const TextStyle(fontSize: 12)),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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
