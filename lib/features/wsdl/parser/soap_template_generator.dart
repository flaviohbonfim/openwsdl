import 'package:soap_lite/features/wsdl/models/soap_operation.dart';

class SoapTemplateGenerator {
  static String generate(SoapOperation op) {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="utf-8"?>');
    sb.writeln(
        '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
    sb.writeln('               xmlns:xsd="http://www.w3.org/2001/XMLSchema"');
    sb.writeln(
        '               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">');
    sb.writeln('  <soap:Body>');

    final ns =
        op.targetNamespace != null ? ' xmlns="${op.targetNamespace}"' : '';
    sb.writeln('    <${op.name}$ns>');

    for (var param in op.parameters) {
      _writeParameter(sb, param, 3);
    }

    sb.writeln('    </${op.name}>');
    sb.writeln('  </soap:Body>');
    sb.writeln('</soap:Envelope>');

    return sb.toString();
  }

  static void _writeParameter(
      StringBuffer sb, SoapParameter param, int indentLevel) {
    final indent = '  ' * indentLevel;
    if (param.children.isEmpty) {
      sb.writeln(
          '$indent<${param.name}><!-- Type: ${param.type} --></${param.name}>');
    } else {
      sb.writeln('$indent<${param.name}>');
      for (var child in param.children) {
        _writeParameter(sb, child, indentLevel + 1);
      }
      sb.writeln('$indent</${param.name}>');
    }
  }
}
