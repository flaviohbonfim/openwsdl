import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/tab_manager.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tabManager = context.watch<TabManager>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 38,
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabManager.tabs.length, (index) {
                  final tab = tabManager.tabs[index];
                  final isActive = tabManager.activeTabIndex == index;

                  return _TabWidget(
                    title: tab.title,
                    isModified: tab.isModified,
                    isActive: isActive,
                    onTap: () => tabManager.setActiveTab(index),
                    onClose: () => tabManager.closeTab(index),
                  );
                }),
              ),
            ),
          ),
          // Botão para nova aba
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => tabManager.addTab(),
            tooltip: 'Nova Requisição (Ctrl+T)',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _TabWidget extends StatelessWidget {
  final String title;
  final bool isModified;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabWidget({
    required this.title,
    required this.isModified,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surface : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
            bottom: BorderSide(
              color: isActive ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 14,
              color: isActive ? colorScheme.primary : theme.hintColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? colorScheme.onSurface : theme.hintColor,
                ),
              ),
            ),
            if (isModified)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClose,
              child: Icon(
                Icons.close,
                size: 14,
                color: theme.hintColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
