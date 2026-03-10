import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/environment_provider.dart';
import 'environment_manager_modal.dart';

class EnvironmentSelector extends StatelessWidget {
  const EnvironmentSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final envProvider = context.watch<EnvironmentProvider>();
    final activeEnv = envProvider.activeEnvironment;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.public,
            size: 14,
            color: activeEnv != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: envProvider.activeEnvironmentId,
              isDense: true,
              hint: const Text('No Environment', style: TextStyle(fontSize: 12)),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No Environment'),
                ),
                ...envProvider.environments.map((env) {
                  return DropdownMenuItem<String?>(
                    value: env.id,
                    child: Text(env.name),
                  );
                }),
              ],
              onChanged: (String? value) {
                envProvider.setActiveEnvironment(value);
              },
            ),
          ),
          const SizedBox(width: 4),
          VerticalDivider(
            width: 16,
            indent: 8,
            endIndent: 8,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const EnvironmentManagerModal(),
              );
            },
            tooltip: 'Manage Environments',
          ),
        ],
      ),
    );
  }
}
