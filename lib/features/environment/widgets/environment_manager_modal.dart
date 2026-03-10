import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/environment_provider.dart';
import '../models/environment_model.dart';

class EnvironmentManagerModal extends StatefulWidget {
  const EnvironmentManagerModal({super.key});

  @override
  State<EnvironmentManagerModal> createState() => _EnvironmentManagerModalState();
}

class _EnvironmentManagerModalState extends State<EnvironmentManagerModal> {
  String? _selectedEnvId;

  @override
  void initState() {
    super.initState();
    final provider = context.read<EnvironmentProvider>();
    _selectedEnvId = provider.activeEnvironmentId ?? (provider.environments.isNotEmpty ? provider.environments.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnvironmentProvider>();
    final environments = provider.environments;
    final selectedEnv = environments.where((e) => e.id == _selectedEnvId).firstOrNull;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Environments',
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar - Environments List
                  SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Environments',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => _showAddEnvironmentDialog(context, provider),
                              tooltip: 'Add Environment',
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: environments.length,
                            itemBuilder: (context, index) {
                              final env = environments[index];
                              final isSelected = env.id == _selectedEnvId;
                              return ListTile(
                                dense: true,
                                selected: isSelected,
                                title: Text(env.name),
                                trailing: isSelected
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy, size: 14),
                                            onPressed: () => provider.duplicateEnvironment(env.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 14),
                                            onPressed: () => provider.deleteEnvironment(env.id),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedEnvId = env.id;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 32),
                  // Content - Variables Editor
                  Expanded(
                    child: selectedEnv == null
                        ? const Center(child: Text('Select an environment to edit'))
                        : _VariablesEditor(
                            environment: selectedEnv,
                            onUpdate: (updatedEnv) => provider.updateEnvironment(updatedEnv),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEnvironmentDialog(BuildContext context, EnvironmentProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Environment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Environment Name',
            hintText: 'e.g. Production, Staging',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.createEnvironment(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _VariablesEditor extends StatefulWidget {
  final Environment environment;
  final Function(Environment) onUpdate;

  const _VariablesEditor({
    required this.environment,
    required this.onUpdate,
  });

  @override
  State<_VariablesEditor> createState() => _VariablesEditorState();
}

class _VariablesEditorState extends State<_VariablesEditor> {
  late List<EnvironmentVariable> _variables;
  final _keyControllers = <TextEditingController>[];
  final _valueControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(_VariablesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environment.id != widget.environment.id) {
      _disposeControllers();
      _initControllers();
    }
  }

  void _initControllers() {
    _variables = List.from(widget.environment.variables);
    _keyControllers.clear();
    _valueControllers.clear();
    for (var v in _variables) {
      _keyControllers.add(TextEditingController(text: v.key));
      _valueControllers.add(TextEditingController(text: v.value));
    }
    // Add an empty row for new variables
    _addEmptyRow();
  }

  void _addEmptyRow() {
    _variables.add(EnvironmentVariable(key: '', value: ''));
    _keyControllers.add(TextEditingController());
    _valueControllers.add(TextEditingController());
  }

  void _disposeControllers() {
    for (var c in _keyControllers) {
      c.dispose();
    }
    for (var c in _valueControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _notifyUpdate() {
    final validVars = <EnvironmentVariable>[];
    for (int i = 0; i < _variables.length; i++) {
      final key = _keyControllers[i].text.trim();
      final value = _valueControllers[i].text;
      if (key.isNotEmpty) {
        validVars.add(EnvironmentVariable(
          key: key,
          value: value,
          enabled: _variables[i].enabled,
        ));
      }
    }
    widget.onUpdate(widget.environment.copyWith(variables: validVars));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Variables for ${widget.environment.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _variables.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _variables[index].enabled,
                      onChanged: (val) {
                        setState(() {
                          _variables[index] = _variables[index].copyWith(enabled: val ?? true);
                        });
                        _notifyUpdate();
                      },
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _keyControllers[index],
                        decoration: const InputDecoration(
                          hintText: 'Key',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (val) {
                          if (index == _variables.length - 1 && val.isNotEmpty) {
                            setState(() {
                              _addEmptyRow();
                            });
                          }
                          _notifyUpdate();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _valueControllers[index],
                        decoration: const InputDecoration(
                          hintText: 'Value',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (val) {
                          if (index == _variables.length - 1 && val.isNotEmpty) {
                            setState(() {
                              _addEmptyRow();
                            });
                          }
                          _notifyUpdate();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: index == _variables.length - 1 && _keyControllers[index].text.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _keyControllers[index].dispose();
                                _valueControllers[index].dispose();
                                _keyControllers.removeAt(index);
                                _valueControllers.removeAt(index);
                                _variables.removeAt(index);
                              });
                              _notifyUpdate();
                            },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
