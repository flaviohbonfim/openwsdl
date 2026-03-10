class SoapOperation {
  final String name;
  final String? soapAction;
  final String endpoint;
  final String? targetNamespace;
  final List<SoapParameter> parameters;
  final String? documentation;
  final Map<String, String> namespaces; // URI -> Prefix

  SoapOperation({
    required this.name,
    this.soapAction,
    required this.endpoint,
    this.targetNamespace,
    this.parameters = const [],
    this.documentation,
    this.namespaces = const {},
  });

  @override
  String toString() => 'SoapOperation(name: $name, action: $soapAction)';
}

class SoapParameter {
  final String name;
  final String type;
  final bool isComplex;
  final List<SoapParameter> children;
  final String? namespace;
  final String? preferredPrefix;

  SoapParameter({
    required this.name,
    required this.type,
    this.isComplex = false,
    this.children = const [],
    this.namespace,
    this.preferredPrefix,
  });
}
