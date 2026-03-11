import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_monaco/flutter_monaco.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';
import '../controller/tab_manager.dart';
import '../controller/tab_editor_state.dart';
import '../../environment/controller/environment_provider.dart';
import '../../../config/theme/theme_provider.dart';
import 'dart:async';

class MonacoEditorWidget extends StatefulWidget {
  final TabEditorState tab;
  final VoidCallback? onSave;
  final VoidCallback? onExecuteRequest;

  const MonacoEditorWidget({
    super.key,
    required this.tab,
    this.onSave,
    this.onExecuteRequest,
  });

  @override
  State<MonacoEditorWidget> createState() => MonacoEditorWidgetState();
}

class MonacoEditorWidgetState extends State<MonacoEditorWidget> {
  MonacoController? _controller;
  bool _initialized = false;
  String? _registrationId;

  @override
  void dispose() {
    if (_registrationId != null && _controller != null) {
      _controller!.unregisterCompletionSource(_registrationId!);
    }
    super.dispose();
  }

  Future<void> format() async {
    if (_controller == null) return;

    try {
      final content = await _controller!.getValue();
      if (content.trim().isEmpty) return;

      final document = XmlDocument.parse(content);
      final formatted = document.toXmlString(pretty: true, indent: '  ');

      await _controller!.setValue(formatted);

      // Feedback visual opcional
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('XML Formatado'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao formatar XML: ${e.toString().split('\n').first}')),
        );
      }
    }
  }

  void setValue(String value) {
    _controller?.setValue(value);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MonacoEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab.id != widget.tab.id &&
        _initialized &&
        _controller != null) {
      _controller!.setValue(widget.tab.content);
      _controller!.setLanguage(
        widget.tab.language == 'xml'
            ? MonacoLanguage.xml
            : MonacoLanguage.plaintext,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final monacoTheme = isDark ? MonacoTheme.vsDark : MonacoTheme.vs;
    final monacoLanguage = widget.tab.language == 'xml'
        ? MonacoLanguage.xml
        : MonacoLanguage.plaintext;

    return MonacoEditor(
      initialValue: widget.tab.content,
      options: EditorOptions(
        theme: monacoTheme,
        language: monacoLanguage,
      ),
      onReady: (controller) {
        setState(() {
          _controller = controller;
          _initialized = true;
        });
        _setupVariableFeatures();
      },
      onContentChanged: (value) {
        if (value != widget.tab.content) {
          context.read<TabManager>().updateActiveTabContent(value);
          _updateVariableFeatures(value);
        }
      },
      onSelectionChanged: (range) {
        if (range != null && range.startLine == 9999999) {
          if (range.startColumn == 1) {
            widget.onSave?.call();
          } else if (range.startColumn == 2) {
            widget.onExecuteRequest?.call();
          }
          return;
        }
      },
      customCss: '''
        .env-var-highlight {
          color: #ff9800 !important;
          font-weight: bold;
          text-decoration: underline dotted #ff9800;
          cursor: help;
        }
        /* Fallback para forçar o Monaco a processar o hoverMessage corretamente */
        .monaco-editor .hover-contents * {
          user-select: text;
        }
        </style>
        <script>
          document.addEventListener('keydown', function(e) {
            let action = null;
            if (e.ctrlKey && e.key.toLowerCase() === 's') {
              action = 1;
            } else if (e.ctrlKey && e.key === 'Enter') {
              action = 2;
            }
            
            if (action !== null) {
              e.preventDefault();
              e.stopPropagation();
              var msg = JSON.stringify({
                event: 'selectionChanged',
                selection: {
                  startLineNumber: 9999999,
                  endLineNumber: 9999999,
                  startColumn: action,
                  endColumn: action
                }
              });
              if (window.flutterMonacoPostMessage) {
                window.flutterMonacoPostMessage(msg);
              } else if (window.flutterChannel && window.flutterChannel.postMessage) {
                window.flutterChannel.postMessage(msg);
              }
            }
          }, true);
        </script>
        <style>
      ''',
    );
  }

  void _setupVariableFeatures() {
    if (_controller == null) return;

    // 1. Initial updates
    _updateVariableFeatures(widget.tab.content);
    _updateAutocomplete();
  }

  // Improved listener setup
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-trigger updates when environment changes via Provider
    // We use context.watch implicitly here if we were in build, 
    // but since we are in didChangeDependencies, we can use listen: true
    Provider.of<EnvironmentProvider>(context);
    
    if (_initialized && _controller != null) {
      _updateVariableFeatures(widget.tab.content);
      _updateAutocomplete();
    }
  }

  Future<void> _updateVariableFeatures(String content) async {
    if (_controller == null || !_initialized) return;

    final envProvider = Provider.of<EnvironmentProvider>(context, listen: false);
    final variables = envProvider.getActiveVariables();
    final variableRegex = RegExp(r'\{\{([^{}]+)\}\}');
    
    final lines = content.split('\n');
    final List<DecorationOptions> decorations = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final matches = variableRegex.allMatches(line);
      
      for (final match in matches) {
        final varName = match.group(1)!.trim();
        final startLine = i + 1;
        final startCol = match.start + 1;
        final endCol = match.end + 1;
        
        String hoverMessage;
        if (varName.startsWith('\$')) {
          hoverMessage = 'Variable Dinâmica: $varName';
        } else if (envProvider.activeEnvironmentId == null) {
          hoverMessage = 'Nenhum ambiente selecionado';
        } else {
          final value = variables[varName];
          hoverMessage = (value != null && value.toString().trim().isNotEmpty)
              ? 'Valor Atual: $value' 
              : 'Variável "$varName" não encontrada ou vazia no ambiente ativo';
        }

        debugPrint('Variable detected: "$varName", hover message: "$hoverMessage"');

        decorations.add(DecorationOptions.inlineClass(
          range: Range(
            startLine: startLine,
            startColumn: startCol,
            endLine: startLine,
            endColumn: endCol,
          ),
          className: 'env-var-highlight',
          hoverMessage: hoverMessage,
        ));
      }
    }

    await _controller!.setDecorations(decorations);
  }

  Future<void> _updateAutocomplete() async {
    if (_controller == null || !_initialized) return;

    if (_registrationId != null) {
      await _controller!.unregisterCompletionSource(_registrationId!);
    }

    final envProvider = Provider.of<EnvironmentProvider>(context, listen: false);
    final variables = envProvider.getActiveVariables();
    
    final suggestions = variables.entries.map((e) => CompletionItem(
      label: '{{${e.key}}}',
      kind: CompletionItemKind.variable,
      insertText: '{{${e.key}}}',
      detail: 'Value: ${e.value}',
      documentation: 'Variável de ambiente',
    )).toList();

    // Adicionar variáveis dinâmicas
    suggestions.addAll([
      CompletionItem(
        label: '{{\$guid}}',
        kind: CompletionItemKind.snippet,
        insertText: '{{\$guid}}',
        detail: 'Gera um UUID v4',
      ),
      CompletionItem(
        label: '{{\$timestamp}}',
        kind: CompletionItemKind.snippet,
        insertText: '{{\$timestamp}}',
        detail: 'Timestamp atual (ms)',
      ),
      CompletionItem(
        label: '{{\$isoTimestamp}}',
        kind: CompletionItemKind.snippet,
        insertText: '{{\$isoTimestamp}}',
        detail: 'Data/Hora em formato ISO',
      ),
    ]);

    _registrationId = await _controller!.registerStaticCompletions(
      languages: ['xml', 'plaintext'],
      items: suggestions,
      triggerCharacters: ['{'],
    );
  }
}
