import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';
import 'package:soap_lite/features/wsdl/models/soap_operation.dart';
import 'package:soap_lite/features/wsdl/models/wsdl_definition.dart';

import 'xsd_mapper.dart';

class WsdlParserService {
  final http.Client _client = http.Client();

  Future<WsdlDefinition> parseFromUrl(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Falha ao baixar WSDL de $url: ${response.statusCode}');
    }

    return parse(response.body, url);
  }

  WsdlDefinition parse(String xmlContent, String sourceUrl) {
    try {
      final document = XmlDocument.parse(xmlContent);
      final definitions = document.getElement('wsdl:definitions') ??
          document.getElement('definitions');

      if (definitions == null) {
        throw Exception('Elemento wsdl:definitions não encontrado na raiz.');
      }

      final targetNamespace = definitions.getAttribute('targetNamespace');
      final services = <WsdlService>[];

      final serviceElements = definitions.findElements('wsdl:service');
      if (serviceElements.isEmpty) {
        // Tenta sem o prefixo wsdl
        final alternateServices = definitions.findElements('service');
        for (var serviceEl in alternateServices) {
          services.add(_parseService(definitions, serviceEl));
        }
      } else {
        for (var serviceEl in serviceElements) {
          services.add(_parseService(definitions, serviceEl));
        }
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

  WsdlService _parseService(XmlElement definitions, XmlElement serviceEl) {
    final name = serviceEl.getAttribute('name') ?? 'Serviço sem nome';
    final ports = <WsdlPort>[];

    final portElements = serviceEl.findElements('wsdl:port');
    if (portElements.isEmpty) {
      final alternatePorts = serviceEl.findElements('port');
      for (var portEl in alternatePorts) {
        ports.add(_parsePort(definitions, portEl));
      }
    } else {
      for (var portEl in portElements) {
        ports.add(_parsePort(definitions, portEl));
      }
    }

    return WsdlService(name: name, ports: ports);
  }

  WsdlPort _parsePort(XmlElement definitions, XmlElement portEl) {
    final name = portEl.getAttribute('name') ?? 'Porta sem nome';
    final bindingQualifiedName = portEl.getAttribute('binding');
    final bindingName = bindingQualifiedName?.split(':').last;

    // Address (endpoint)
    String endpoint = '';
    final addressEl = portEl.findElements('soap:address').firstOrNull ??
        portEl.findElements('soap12:address').firstOrNull ??
        portEl.findElements('address').firstOrNull;

    if (addressEl != null) {
      endpoint = addressEl.getAttribute('location') ?? '';
    }

    // Se houver um binding, podemos encontrar as operações associadas
    List<SoapOperation> operations = [];
    if (bindingName != null) {
      operations = _findOperationsInBinding(definitions, bindingName, endpoint);
    }

    return WsdlPort(name: name, endpoint: endpoint, operations: operations);
  }

  List<SoapOperation> _findOperationsInBinding(
      XmlElement definitions, String bindingName, String endpoint) {
    final operations = <SoapOperation>[];
    final mapper = XsdMapper(definitions);

    final bindings = definitions.findElements('wsdl:binding');
    final targetBinding =
        bindings.firstWhereOrNull((b) => b.getAttribute('name') == bindingName);

    if (targetBinding != null) {
      final portTypeName = targetBinding.getAttribute('type')?.split(':').last;
      final portTypes = definitions.findElements('wsdl:portType');
      final targetPortType = portTypes
          .firstWhereOrNull((p) => p.getAttribute('name') == portTypeName);

      final bindingOperations = targetBinding.findElements('wsdl:operation');
      for (var opEl in bindingOperations) {
        final opName = opEl.getAttribute('name');
        if (opName == null) continue;

        final soapOpEl = opEl.findElements('soap:operation').firstOrNull ??
            opEl.findElements('soap12:operation').firstOrNull;

        final soapAction = soapOpEl?.getAttribute('soapAction');

        // Busca a entrada nos portTypes
        final portTypeOperation = targetPortType
            ?.findElements('wsdl:operation')
            .firstWhereOrNull((o) => o.getAttribute('name') == opName);

        final inputMessageName = portTypeOperation
            ?.findElements('wsdl:input')
            .firstOrNull
            ?.getAttribute('message')
            ?.split(':')
            .last;

        List<SoapParameter> parameters = [];
        if (inputMessageName != null) {
          try {
            parameters = mapper.getParametersForMessage(inputMessageName);
          } catch (e) {
            print('Erro ao obter parâmetros para operação $opName: $e');
          }
        }

        operations.add(SoapOperation(
          name: opName,
          soapAction: soapAction,
          endpoint: endpoint,
          parameters: parameters,
        ));
      }
    }

    return operations;
  }
}
