import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soap_lite/features/wsdl/wsdl_provider.dart';

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
