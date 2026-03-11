import 'package:openwsdl/features/wsdl/models/soap_operation.dart';

class WsdlService {
  final String name;
  final List<WsdlPort> ports;

  WsdlService({required this.name, this.ports = const []});
}

class WsdlPort {
  final String name;
  final String endpoint;
  final List<SoapOperation> operations;

  WsdlPort({
    required this.name,
    required this.endpoint,
    this.operations = const [],
  });
}

class WsdlDefinition {
  final String? targetNamespace;
  final List<WsdlService> services;
  final String sourceUrl;
  final String? version;
  bool isLoaded;

  WsdlDefinition({
    required this.sourceUrl,
    this.targetNamespace,
    this.services = const [],
    this.version,
    this.isLoaded = false,
  });

  @override
  String toString() =>
      'WsdlDefinition(sourceUrl: $sourceUrl, namespace: $targetNamespace)';
}
