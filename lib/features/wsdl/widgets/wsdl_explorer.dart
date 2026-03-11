import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openwsdl/features/wsdl/models/soap_operation.dart';
import 'package:openwsdl/features/wsdl/models/wsdl_definition.dart';
import 'package:openwsdl/features/wsdl/wsdl_provider.dart';
import 'package:openwsdl/features/editor/controller/tab_manager.dart';
import 'package:openwsdl/features/wsdl/parser/soap_template_generator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WsdlExplorer extends StatelessWidget {
  const WsdlExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    final wsdlProvider = context.watch<WsdlProvider>();
    final definitions = wsdlProvider.definitions;

    if (definitions.isEmpty) {
      return _buildEmptyState(context)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0);
    }

    return Column(
      children: [
        if (wsdlProvider.isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ).animate().fadeIn(),
        Expanded(
          child: ListView.builder(
            itemCount: definitions.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final wsdl = definitions[index];
              return _buildWsdlNode(context, wsdl, wsdlProvider)
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.05, end: 0);
            },
          ),
        ),
      ],
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

  Widget _buildWsdlNode(
      BuildContext context, WsdlDefinition wsdl, WsdlProvider provider) {
    if (!wsdl.isLoaded) {
      return GestureDetector(
        onDoubleTap: () => provider.loadWsdl(wsdl),
        child: ListTile(
          leading:
              const Icon(Icons.cloud_download, size: 18, color: Colors.grey),
          title: Text(
            wsdl.sourceUrl.split('/').last,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: const Text(
            'Clique duas vezes para carregar',
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => provider.removeWsdl(wsdl),
            tooltip: 'Remover WSDL',
          ),
        ),
      );
    }

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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => provider.removeWsdl(wsdl),
            tooltip: 'Remover WSDL',
          ),
          const Icon(Icons.expand_more, size: 18),
        ],
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
    final tabManager = context.read<TabManager>();
    tabManager.addTab(
      title: op.name,
      content: SoapTemplateGenerator.generate(op),
      endpoint: op.endpoint,
      soapAction: op.soapAction,
    );
  }
}
