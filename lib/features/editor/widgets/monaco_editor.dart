import 'package:flutter/material.dart';
import 'package:flutter_monaco/flutter_monaco.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';
import '../controller/tab_manager.dart';
import '../controller/tab_editor_state.dart';
import '../../../config/theme/theme_provider.dart';

class MonacoEditorWidget extends StatefulWidget {
  final TabEditorState tab;

  const MonacoEditorWidget({
    super.key,
    required this.tab,
  });

  @override
  State<MonacoEditorWidget> createState() => MonacoEditorWidgetState();
}

class MonacoEditorWidgetState extends State<MonacoEditorWidget> {
  MonacoController? _controller;
  bool _initialized = false;

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
      },
      onContentChanged: (value) {
        if (value != widget.tab.content) {
          context.read<TabManager>().updateActiveTabContent(value);
        }
      },
    );
  }
}
