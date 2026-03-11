import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:openwsdl/features/wsdl/models/soap_operation.dart';

class XsdMapper {
  final XmlElement definitions;
  final List<XmlElement> allSchemas;
  final Map<String, String> namespaceToPrefix;

  XsdMapper(this.definitions, this.allSchemas, this.namespaceToPrefix);

  /// Busca filhos diretos pelo nome local, ignorando o prefixo (funciona para xsd:, xs: ou nenhum prefixo)
  Iterable<XmlElement> _findChildrenByLocalName(
      XmlElement parent, String localName) {
    return parent.children
        .whereType<XmlElement>()
        .where((el) => el.localName == localName);
  }

  List<SoapParameter> getParametersForMessage(String messageName) {
    // Busca mensagens ignorando prefixo do WSDL
    final messages = definitions.children
        .whereType<XmlElement>()
        .where((el) => el.localName == 'message');

    final message = messages.firstWhereOrNull(
      (m) => m.getAttribute('name') == messageName,
    );

    if (message == null)
      throw Exception('Mensagem $messageName não encontrada');

    final parameters = <SoapParameter>[];
    final parts = _findChildrenByLocalName(message, 'part');

    for (var part in parts) {
      final elementQualifiedName = part.getAttribute('element');
      final typeQualifiedName = part.getAttribute('type');
      final partName = part.getAttribute('name') ?? '';

      if (elementQualifiedName != null) {
        final nsPrefix = elementQualifiedName.split(':').firstOrNull;
        final localName = elementQualifiedName.split(':').last;
        final ns = nsPrefix != null && elementQualifiedName.contains(':')
            ? _getNamespaceForPrefix(nsPrefix, part)
            : null;

        parameters.addAll(_getParametersByElementName(localName, ns));
      } else if (typeQualifiedName != null) {
        final typeParts = typeQualifiedName.split(':');
        final prefix = typeParts.length > 1 ? typeParts.first : null;
        final typeName = typeParts.last;
        final ns = prefix != null ? _getNamespaceForPrefix(prefix, part) : null;

        final children = _getParametersByTypeName(typeName, ns, 0);
        parameters.add(SoapParameter(
          name: partName,
          type: typeName,
          isComplex: children.isNotEmpty,
          children: children,
          namespace: ns,
          preferredPrefix: prefix,
        ));
      }
    }

    return parameters;
  }

  String? _getNamespaceForPrefix(String prefix, [XmlElement? context]) {
    if (context != null) {
      // Busca no elemento atual e sobe na árvore (incluindo namespaces definidos no schema)
      XmlNode? current = context;
      while (current != null && current is XmlElement) {
        final ns = current.getAttribute('xmlns:$prefix');
        if (ns != null) return ns;
        current = current.parent;
      }
    }

    // Procura nas definições WSDL root
    final ns = definitions.getAttribute('xmlns:$prefix');
    if (ns != null) return ns;

    // Busca reversa no mapa global se houver (opcional, pode ser arriscado)
    return namespaceToPrefix.entries
        .firstWhereOrNull((e) => e.value == prefix)
        ?.key;
  }

  List<SoapParameter> _getParametersFromComplexType(
      XmlElement complexType, String? targetNs,
      [int depth = 0]) {
    if (depth > 16) return []; // Aumentada profundidade máxima

    final sequence =
        _findChildrenByLocalName(complexType, 'sequence').firstOrNull ??
            _findChildrenByLocalName(complexType, 'all').firstOrNull ??
            _findChildrenByLocalName(complexType, 'choice').firstOrNull;

    final parameters = <SoapParameter>[];

    if (sequence != null) {
      final elements = _findChildrenByLocalName(sequence, 'element');

      for (var el in elements) {
        final name = el.getAttribute('name') ?? '';
        final typeQualifiedName = el.getAttribute('type');

        if (typeQualifiedName == null) {
          // Pode ser um tipo complexo anônimo definido dentro do elemento
          final innerComplexType =
              _findChildrenByLocalName(el, 'complexType').firstOrNull;
          if (innerComplexType != null) {
            final children = _getParametersFromComplexType(
                innerComplexType, targetNs, depth + 1);
            parameters.add(SoapParameter(
              name: name,
              type: 'anonymous',
              isComplex: true,
              children: children,
              namespace: targetNs,
            ));
          }
          continue;
        }

        final typeParts = typeQualifiedName.split(':');
        final prefix = typeParts.length > 1 ? typeParts.first : null;
        final type = typeParts.last;
        final ns =
            prefix != null ? _getNamespaceForPrefix(prefix, el) : targetNs;

        // Ao encontrar um elemento com tipo, buscamos pelo NOME DO TIPO usando o namespace do tipo
        final children = _getParametersByTypeName(type, ns, depth + 1);

        parameters.add(SoapParameter(
          name: name,
          type: type,
          isComplex: children.isNotEmpty,
          children: children,
          namespace: targetNs, // O elemento pertence ao namespace do esquema
          preferredPrefix: null,
        ));
      }
    }

    // herança
    final complexContent =
        _findChildrenByLocalName(complexType, 'complexContent').firstOrNull;
    if (complexContent != null) {
      final extension =
          _findChildrenByLocalName(complexContent, 'extension').firstOrNull;
      if (extension != null) {
        final baseQualifiedName = extension.getAttribute('base');
        if (baseQualifiedName != null) {
          final baseParts = baseQualifiedName.split(':');
          final basePrefix = baseParts.length > 1 ? baseParts.first : null;
          final baseType = baseParts.last;
          final baseNs = basePrefix != null
              ? _getNamespaceForPrefix(basePrefix, extension)
              : targetNs;

          // Adiciona campos da base
          parameters
              .addAll(_getParametersByTypeName(baseType, baseNs, depth + 1));

          // Adiciona campos da própria extensão
          parameters.addAll(
              _getParametersFromComplexType(extension, targetNs, depth + 1));
        }
      }
    }

    return parameters;
  }

  List<SoapParameter> _getParametersByElementName(
      String elementName, String? namespace,
      [int depth = 0]) {
    if (depth > 16) return [];

    for (var schema in allSchemas) {
      final targetNs = schema.getAttribute('targetNamespace');
      if (namespace != null && targetNs != namespace) continue;

      final elements = _findChildrenByLocalName(schema, 'element');
      final element = elements
          .firstWhereOrNull((e) => e.getAttribute('name') == elementName);

      if (element != null) {
        final complexType =
            _findChildrenByLocalName(element, 'complexType').firstOrNull;
        if (complexType != null) {
          return _getParametersFromComplexType(complexType, targetNs, depth);
        }

        final typeAttr = element.getAttribute('type');
        if (typeAttr != null) {
          final parts = typeAttr.split(':');
          final prefix = parts.length > 1 ? parts.first : null;
          final typeName = parts.last;
          final ns = prefix != null
              ? _getNamespaceForPrefix(prefix, element)
              : targetNs;

          return _getParametersByTypeName(typeName, ns, depth + 1);
        }
      }
    }
    return [];
  }

  List<SoapParameter> _getParametersByTypeName(
      String typeName, String? namespace,
      [int depth = 0]) {
    if (depth > 16) return [];

    // Ignora tipos básicos XML
    const basicTypes = {
      'string',
      'int',
      'long',
      'boolean',
      'dateTime',
      'decimal',
      'float',
      'double',
      'base64Binary',
      'anyType',
      'duration',
      'char'
    };
    if (basicTypes.contains(typeName.toLowerCase())) return [];

    for (var schema in allSchemas) {
      final targetNs = schema.getAttribute('targetNamespace');
      if (namespace != null && targetNs != namespace) continue;

      final complexTypes = _findChildrenByLocalName(schema, 'complexType');
      final complexType = complexTypes
          .firstWhereOrNull((t) => t.getAttribute('name') == typeName);

      if (complexType != null) {
        return _getParametersFromComplexType(complexType, targetNs, depth);
      }

      // Também procurar em simpleType para evitar erros se for um enum, etc
      final simpleTypes = _findChildrenByLocalName(schema, 'simpleType');
      if (simpleTypes.any((t) => t.getAttribute('name') == typeName)) {
        return [];
      }
    }
    return [];
  }
}
