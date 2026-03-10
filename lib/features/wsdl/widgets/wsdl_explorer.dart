import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soap_lite/features/wsdl/models/soap_operation.dart';
import 'package:soap_lite/features/wsdl/models/wsdl_definition.dart';
import 'package:soap_lite/features/wsdl/wsdl_provider.dart';
import 'package:soap_lite/features/editor/controller/tab_manager.dart';
import 'package:soap_lite/features/wsdl/parser/soap_template_generator.dart';

class WsdlExplorer extends StatelessWidget {
  const WsdlExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    final wsdlProvider = context.watch<WsdlProvider>();
    final definitions = wsdlProvider.definitions;

    if (definitions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: definitions.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final wsdl = definitions[index];
        return _buildWsdlNode(context, wsdl);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'Nenhum WSDL importado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Clique no botão de importar para carregar uma definição de serviço.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWsdlNode(BuildContext context, WsdlDefinition wsdl) {
    return ExpansionTile(
      leading: const Icon(Icons.description, size: 18, color: Colors.orange),
      title: Text(
        wsdl.sourceUrl.split('/').last,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        wsdl.targetNamespace ?? '',
        style: const TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
      children: wsdl.services
          .map((service) => _buildServiceNode(context, service))
          .toList(),
    );
  }

  Widget _buildServiceNode(BuildContext context, WsdlService service) {
    return ExpansionTile(
      leading: const Icon(Icons.settings, size: 16),
      title: Text(
        service.name,
        style: const TextStyle(fontSize: 12),
      ),
      children:
          service.ports.map((port) => _buildPortNode(context, port)).toList(),
    );
  }

  Widget _buildPortNode(BuildContext context, WsdlPort port) {
    return ExpansionTile(
      leading: const Icon(Icons.lan, size: 16),
      title: Text(
        port.name,
        style: const TextStyle(fontSize: 12),
      ),
      children: port.operations
          .map((op) => _buildOperationNode(context, op))
          .toList(),
    );
  }

  Widget _buildOperationNode(BuildContext context, SoapOperation op) {
    return ListTile(
      leading: const Icon(Icons.play_arrow, size: 16, color: Colors.green),
      title: Text(
        op.name,
        style: const TextStyle(fontSize: 12),
      ),
      dense: true,
      onTap: () {
        _handleOperationSelected(context, op);
      },
    );
  }

  void _handleOperationSelected(BuildContext context, SoapOperation op) {
    // TODO: Integrar com TabManager para abrir aba com template
    final tabManager = context.read<TabManager>();
    tabManager.addTab(
      title: op.name,
      content: SoapTemplateGenerator.generate(op),
    );
  }
}
