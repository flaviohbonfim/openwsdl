import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:openwsdl/features/wsdl/models/soap_operation.dart';
import 'package:openwsdl/features/wsdl/models/wsdl_definition.dart';

import 'xsd_mapper.dart';

class WsdlParserService {
  final http.Client _client = http.Client();

  Future<WsdlDefinition> parseFromUrl(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
          
      if (response.statusCode != 200) {
        throw Exception('Falha ao baixar WSDL de $url (Status: ${response.statusCode})');
      }

      return await parse(response.body, url);
    } on http.ClientException catch (e) {
      throw Exception('Erro de rede ao acessar o WSDL: $e');
    } on Exception {
      rethrow;

    } catch (e) {
      throw Exception('Ocorreu um erro inesperado ao carregar o WSDL: $e');
    }
  }

  Future<WsdlDefinition> parseFromContent(String xmlContent, String sourceName) async {
    return await parse(xmlContent, sourceName);
  }


  Future<WsdlDefinition> parse(String xmlContent, String sourceUrl) async {
    try {
      final document = XmlDocument.parse(xmlContent);
      var definitions = document.getElement('wsdl:definitions') ??
          document.getElement('definitions');

      // SoapUI Project support
      if (definitions == null) {
        final soapuiProject = document.getElement('con:soapui-project');
        if (soapuiProject != null) {
          // Extrai o conteúdo do primeiro WSDL encontrado (con:content dentro de con:part)
          final wsdlContent = soapuiProject
              .findAllElements('con:content')
              .firstOrNull
              ?.innerText;

          if (wsdlContent != null) {
            final wsdlDoc = XmlDocument.parse(wsdlContent);
            definitions = wsdlDoc.getElement('wsdl:definitions') ??
                wsdlDoc.getElement('definitions');
          }
        }
      }

      if (definitions == null) {
        throw Exception('Elemento wsdl:definitions não encontrado na raiz.');
      }

      final targetNamespace = definitions.getAttribute('targetNamespace');

      // Coleta esquemas locais e recursivos (imports)
      final schemas = await _extractAllSchemas(definitions, sourceUrl);
      final namespaces = _extractNamespaces(definitions, schemas);

      final services = <WsdlService>[];
      final serviceElements = _findWsdlElements(definitions, 'service');

      final context = _ParserContext(
        definitions: definitions,
        schemas: schemas,
        namespaces: namespaces,
      );

      for (var serviceEl in serviceElements) {
        services.add(_parseService(context, serviceEl));
      }

      return WsdlDefinition(
        sourceUrl: sourceUrl,
        targetNamespace: targetNamespace,
        services: services,
      );
    } catch (e) {
      print('Erro ao parsear WSDL: $e');
      rethrow;
    }
  }

  Iterable<XmlElement> _findWsdlElements(XmlElement parent, String name) {
    return parent.children
        .whereType<XmlElement>()
        .where((el) => el.localName == name);
  }

  Map<String, String> _extractNamespaces(
      XmlElement definitions, List<XmlElement> schemas) {
    final map = <String, String>{};

    // 1. Prefixos do WSDL root
    for (var attr in definitions.attributes) {
      if (attr.name.prefix == 'xmlns') {
        map[attr.value] = attr.name.local;
      } else if (attr.name.local == 'xmlns') {
        map[attr.value] = ''; // Default namespace
      }
    }

    // 2. Garante prefixos para todos os targetNamespaces dos esquemas
    int nsCounter = 1;
    for (var schema in schemas) {
      final tns = schema.getAttribute('targetNamespace');
      if (tns != null && !map.containsKey(tns)) {
        // Tenta encontrar um prefixo já definido no próprio esquema
        String? existingPrefix;
        for (var attr in schema.attributes) {
          if (attr.name.prefix == 'xmlns' && attr.value == tns) {
            existingPrefix = attr.name.local;
            break;
          }
        }

        if (existingPrefix != null && !map.containsValue(existingPrefix)) {
          map[tns] = existingPrefix;
        } else {
          // Gera um novo prefixo
          String newPrefix;
          do {
            newPrefix = 'ns$nsCounter';
            nsCounter++;
          } while (map.containsValue(newPrefix));
          map[tns] = newPrefix;
        }
      }
    }

    return map;
  }

  Future<List<XmlElement>> _extractAllSchemas(
      XmlElement definitions, String baseUrl) async {
    final types = _findWsdlElements(definitions, 'types').firstOrNull;
    if (types == null) return [];

    // Busca todos os elementos que terminam com 'schema' (ex: xsd:schema, xs:schema, schema)
    final localSchemas = types.children
        .whereType<XmlElement>()
        .where((el) => el.localName == 'schema')
        .toList();

    final allSchemas = <XmlElement>[...localSchemas];
    final processedUrls = <String>{baseUrl};

    // Busca imports nos esquemas locais
    for (var schema in localSchemas) {
      await _resolveImports(schema, baseUrl, allSchemas, processedUrls);
    }

    return allSchemas;
  }

  Future<void> _resolveImports(XmlElement schema, String baseUrl,
      List<XmlElement> allSchemas, Set<String> processedUrls) async {
    // Busca imports com qualquer prefixo
    final imports = schema.children
        .whereType<XmlElement>()
        .where((el) => el.localName == 'import')
        .toList();

    for (var imp in imports) {
      final schemaLocation = imp.getAttribute('schemaLocation');
      if (schemaLocation == null) continue;

      // Resolve URL absoluta
      String absoluteUrl = schemaLocation;
      if (!schemaLocation.startsWith('http')) {
        final uri = Uri.parse(baseUrl);
        absoluteUrl = uri.resolve(schemaLocation).toString();
      }

      if (processedUrls.contains(absoluteUrl)) continue;
      processedUrls.add(absoluteUrl);

      try {
        print('Baixando esquema importado: $absoluteUrl');
        final response = await _client
            .get(Uri.parse(absoluteUrl))
            .timeout(const Duration(seconds: 10));
            
        if (response.statusCode == 200) {
          final doc = XmlDocument.parse(response.body);
          final root = doc.rootElement;
          if (root.localName == 'schema') {
            allSchemas.add(root);
            // Recursão para buscar imports do esquema importado
            await _resolveImports(root, absoluteUrl, allSchemas, processedUrls);
          }
        }
      } catch (e) {
        print('Erro ao processar import $absoluteUrl: $e');
        // Não jogamos erro aqui para não travar o parse todo se um XSD secundário falhar
      }

    }
  }


  WsdlService _parseService(_ParserContext context, XmlElement serviceEl) {
    final name = serviceEl.getAttribute('name') ?? 'Serviço sem nome';
    final ports = <WsdlPort>[];

    final portElements = _findWsdlElements(serviceEl, 'port');
    for (var portEl in portElements) {
      ports.add(_parsePort(context, portEl));
    }

    return WsdlService(name: name, ports: ports);
  }

  WsdlPort _parsePort(_ParserContext context, XmlElement portEl) {
    final name = portEl.getAttribute('name') ?? 'Porta sem nome';
    final bindingQualifiedName = portEl.getAttribute('binding');
    final bindingName = bindingQualifiedName?.split(':').last;

    String endpoint = '';
    final addressEl = _findWsdlElements(portEl, 'address').firstOrNull;

    if (addressEl != null) {
      endpoint = addressEl.getAttribute('location') ?? '';
    }

    List<SoapOperation> operations = [];
    if (bindingName != null) {
      operations = _findOperationsInBinding(context, bindingName, endpoint);
    }

    return WsdlPort(name: name, endpoint: endpoint, operations: operations);
  }

  List<SoapOperation> _findOperationsInBinding(
      _ParserContext context, String bindingName, String endpoint) {
    final operations = <SoapOperation>[];
    final mapper =
        XsdMapper(context.definitions, context.schemas, context.namespaces);

    final bindings = _findWsdlElements(context.definitions, 'binding');
    final targetBinding =
        bindings.firstWhereOrNull((b) => b.getAttribute('name') == bindingName);

    if (targetBinding != null) {
      final portTypeName = targetBinding.getAttribute('type')?.split(':').last;
      final portTypes = _findWsdlElements(context.definitions, 'portType');
      final targetPortType = portTypes
          .firstWhereOrNull((p) => p.getAttribute('name') == portTypeName);

      final bindingOperations = _findWsdlElements(targetBinding, 'operation');
      for (var opEl in bindingOperations) {
        final opName = opEl.getAttribute('name');
        if (opName == null) continue;

        final soapOpEl = _findWsdlElements(opEl, 'operation').firstOrNull;

        final soapAction = soapOpEl?.getAttribute('soapAction');

        final portTypeOperation = _findWsdlElements(targetPortType!, 'operation')
            .firstWhereOrNull((o) => o.getAttribute('name') == opName);

        final inputMessageRef = _findWsdlElements(portTypeOperation!, 'input')
            .firstOrNull
            ?.getAttribute('message');

        final inputMessageName = inputMessageRef?.split(':').last;

        String? operationTargetNamespace;
        List<SoapParameter> parameters = [];

        if (inputMessageName != null) {
          try {
            parameters = mapper.getParametersForMessage(inputMessageName);

            // Tenta descobrir o namespace da própria operação (o elemento raiz no Body)
            final message = _findWsdlElements(context.definitions, 'message')
                .firstWhereOrNull(
                    (m) => m.getAttribute('name') == inputMessageName);
            if (message != null) {
              final part = _findWsdlElements(message, 'part').firstOrNull;
              final elementAttr = part?.getAttribute('element');
              if (elementAttr != null) {
                final parts = elementAttr.split(':');
                if (parts.length > 1) {
                  operationTargetNamespace =
                      context.definitions.getAttribute('xmlns:${parts.first}');
                } else {
                  operationTargetNamespace =
                      context.definitions.getAttribute('xmlns');
                }
              }
            }
          } catch (e) {
            print('Erro ao obter parâmetros para operação $opName: $e');
          }
        }

        operations.add(SoapOperation(
          name: opName,
          soapAction: soapAction,
          endpoint: endpoint,
          parameters: parameters,
          namespaces: context.namespaces,
          targetNamespace: operationTargetNamespace,
        ));
      }
    }

    return operations;
  }
}

class _ParserContext {
  final XmlElement definitions;
  final List<XmlElement> schemas;
  final Map<String, String> namespaces;

  _ParserContext({
    required this.definitions,
    required this.schemas,
    required this.namespaces,
  });
}
