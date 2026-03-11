import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openwsdl/features/wsdl/wsdl_provider.dart';
import 'package:file_picker/file_picker.dart';

class ImportWsdlDialog extends StatefulWidget {
  const ImportWsdlDialog({super.key});

  @override
  State<ImportWsdlDialog> createState() => _ImportWsdlDialogState();
}

class _ImportWsdlDialogState extends State<ImportWsdlDialog> {
  final _urlController = TextEditingController();
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      await context.read<WsdlProvider>().importWsdl(url);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = 'Erro ao importar: $e';
      });
    }
  }

  Future<void> _handleFileImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wsdl', 'xml'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isImporting = true;
          _errorMessage = null;
        });

        final path = result.files.single.path!;
        final file = File(path);
        final content = await file.readAsString();

        if (mounted) {
          await context.read<WsdlProvider>().importWsdlFromContent(content, path);
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = 'Erro ao ler arquivo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar WSDL'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL do WSDL',
              hintText: 'http://exemplo.com/servico?wsdl',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) => _handleImport(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'OU',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isImporting ? null : _handleFileImport,
            icon: const Icon(Icons.file_open_outlined, size: 18),
            label: const Text('IMPORTAR ARQUIVO LOCAL'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _isImporting ? null : _handleImport,
          child: _isImporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('IMPORTAR'),
        ),
      ],
    );
  }
}
