import 'package:openwsdl/features/wsdl/models/soap_operation.dart';

class SoapTemplateGenerator {
  static String generate(SoapOperation op) {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="utf-8"?>');

    // Mapeamento de prefixos para o envelope
    final namespaces = Map<String, String>.from(op.namespaces);

    // Garantir prefixos padrão
    if (!namespaces.containsValue('soapenv')) {
      namespaces['http://schemas.xmlsoap.org/soap/envelope/'] = 'soapenv';
    }
    if (!namespaces.containsValue('xsi')) {
      namespaces['http://www.w3.org/2001/XMLSchema-instance'] = 'xsi';
    }
    if (!namespaces.containsValue('xsd')) {
      namespaces['http://www.w3.org/2001/XMLSchema'] = 'xsd';
    }

    sb.write('<soapenv:Envelope');
    namespaces.forEach((uri, prefix) {
      if (prefix.isEmpty) {
        sb.write(' xmlns="$uri"');
      } else {
        sb.write(' xmlns:$prefix="$uri"');
      }
    });
    sb.writeln('>');

    sb.writeln('  <soapenv:Header/>');
    sb.writeln('  <soapenv:Body>');

    // Decide o prefixo da operação
    String opPrefix = '';
    if (op.targetNamespace != null) {
      opPrefix = op.namespaces[op.targetNamespace] ?? '';
      if (opPrefix.isNotEmpty) opPrefix = '$opPrefix:';
    }

    sb.writeln('    <$opPrefix${op.name}>');

    for (var param in op.parameters) {
      _writeParameter(sb, param, 3, namespaces);
    }

    sb.writeln('    </$opPrefix${op.name}>');
    sb.writeln('  </soapenv:Body>');
    sb.writeln('</soapenv:Envelope>');

    return sb.toString();
  }

  static void _writeParameter(StringBuffer sb, SoapParameter param,
      int indentLevel, Map<String, String> namespacesMap) {
    final indent = '  ' * indentLevel;

    // Decide o prefixo do parâmetro: prioriza o mapa global de namespaces do WSDL
    String prefix = '';
    if (param.namespace != null) {
      prefix = namespacesMap[param.namespace!] ?? '';
    }

    // Se o namespace não estiver no mapa global, usa o prefixo sugerido pelo parser do esquema
    if (prefix.isEmpty) {
      prefix = param.preferredPrefix ?? '';
    }

    if (prefix.isNotEmpty) prefix = '$prefix:';

    sb.writeln('$indent<!--Optional:-->');

    if (param.children.isEmpty) {
      sb.writeln('$indent<$prefix${param.name}>?</$prefix${param.name}>');
    } else {
      sb.writeln('$indent<$prefix${param.name}>');
      for (var child in param.children) {
        _writeParameter(sb, child, indentLevel + 1, namespacesMap);
      }
      sb.writeln('$indent</$prefix${param.name}>');
    }
  }
}
