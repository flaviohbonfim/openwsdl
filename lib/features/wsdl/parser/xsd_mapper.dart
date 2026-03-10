import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:soap_lite/features/wsdl/models/soap_operation.dart';

class XsdMapper {
  final XmlElement definitions;

  XsdMapper(this.definitions);

  List<SoapParameter> getParametersForMessage(String messageName) {
    // Busca a mensagem pelas definições
    final messages = definitions.findElements('wsdl:message');
    final message = messages.firstWhere(
      (m) => m.getAttribute('name') == messageName,
      orElse: () => throw Exception('Mensagem $messageName não encontrada'),
    );

    final parameters = <SoapParameter>[];
    final parts = message.findElements('wsdl:part');

    for (var part in parts) {
      final elementName = part.getAttribute('element')?.split(':').last;
      final typeName = part.getAttribute('type')?.split(':').last;
      final name = part.getAttribute('name') ?? '';

      if (elementName != null) {
        parameters.addAll(_getParametersFromElement(elementName));
      } else if (typeName != null) {
        parameters.add(SoapParameter(name: name, type: typeName));
        // If it's a simple type directly referenced by 'type' attribute in wsdl:part
        // We still want to check if it's a complex type defined elsewhere
        final children = _getParametersFromElement(typeName);
        parameters.add(SoapParameter(
          name: name,
          type: typeName,
          isComplex: children.isNotEmpty,
          children: children,
        ));
      }
    }

    return parameters;
  }

  List<SoapParameter> _getParametersFromComplexType(XmlElement complexType,
      [int depth = 0]) {
    if (depth > 5) return []; // Evita recursão infinita

    final sequence = complexType.findElements('xsd:sequence').firstOrNull ??
        complexType.findElements('sequence').firstOrNull;

    final parameters = <SoapParameter>[];

    if (sequence != null) {
      final elements = sequence.findElements('xsd:element').isEmpty
          ? sequence.findElements('element')
          : sequence.findElements('xsd:element');

      for (var el in elements) {
        final name = el.getAttribute('name') ?? '';
        final type = el.getAttribute('type')?.split(':').last ?? 'string';

        final children = _getParametersFromElement(type, depth + 1);

        parameters.add(SoapParameter(
          name: name,
          type: type,
          isComplex: children.isNotEmpty,
          children: children,
        ));
      }
    }

    return parameters;
  }

  List<SoapParameter> _getParametersFromElement(String elementName,
      [int depth = 0]) {
    if (depth > 5) return [];

    final types = definitions.findElements('wsdl:types').firstOrNull;
    if (types == null) return [];

    final schemas = types.findElements('xsd:schema').isEmpty
        ? types.findElements('schema')
        : types.findElements('xsd:schema');

    for (var schema in schemas) {
      // Procura por elemento ou tipo complexo com esse nome
      final element = schema
              .findElements('xsd:element')
              .firstWhereOrNull((e) => e.getAttribute('name') == elementName) ??
          schema
              .findElements('element')
              .firstWhereOrNull((e) => e.getAttribute('name') == elementName);

      if (element != null) {
        final complexType =
            element.findElements('xsd:complexType').firstOrNull ??
                element.findElements('complexType').firstOrNull;

        if (complexType != null) {
          return _getParametersFromComplexType(complexType, depth);
        }

        final typeAttr = element.getAttribute('type')?.split(':').last;
        if (typeAttr != null) {
          return _getParametersFromElement(typeAttr, depth + 1);
        }
      }

      final complexType = schema
              .findElements('xsd:complexType')
              .firstWhereOrNull((t) => t.getAttribute('name') == elementName) ??
          schema
              .findElements('complexType')
              .firstWhereOrNull((t) => t.getAttribute('name') == elementName);

      if (complexType != null) {
        return _getParametersFromComplexType(complexType, depth);
      }
    }

    return [];
  }
}
