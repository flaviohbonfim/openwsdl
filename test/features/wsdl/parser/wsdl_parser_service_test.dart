import 'package:flutter_test/flutter_test.dart';
import 'package:openwsdl/features/wsdl/parser/wsdl_parser_service.dart';

void main() {
  group('WsdlParserService - SoapUI Support', () {
    late WsdlParserService parser;

    setUp(() {
      parser = WsdlParserService();
    });

    test('should parse WSDL from SoapUI project XML', () async {
      const soapuiXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<con:soapui-project id="123" name="TestProject" xmlns:con="http://eviware.com/soapui/config">
  <con:interface name="MyBinding">
    <con:definitionCache>
      <con:part>
        <con:content><![CDATA[
<wsdl:definitions name="MyService" targetNamespace="urn:test" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/">
  <wsdl:portType name="MyPortType">
    <wsdl:operation name="MyOperation">
      <wsdl:input message="tns:MyRequest"/>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="MyBinding" type="tns:MyPortType">
    <soap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="MyOperation">
      <soap:operation soapAction="urn:MyOperation"/>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="MyService">
    <wsdl:port name="MyPort" binding="tns:MyBinding">
      <soap:address location="http://localhost/test"/>
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
        ]]></con:content>
      </con:part>
    </con:definitionCache>
  </con:interface>
</con:soapui-project>
''';

      final definition = await parser.parseFromContent(soapuiXml, 'test.xml');

      expect(definition.services, hasLength(1));
      expect(definition.services.first.name, equals('MyService'));
      expect(definition.services.first.ports.first.operations, hasLength(1));
      expect(definition.services.first.ports.first.operations.first.name, equals('MyOperation'));
    });

    test('should parse WSDL with mixed prefixes', () async {
      const mixedPrefixWsdl = '''
<wsdl:definitions name="MyService" targetNamespace="urn:test" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:tns="urn:test">
  <wsdl:portType name="MyPortType">
    <operation name="MyOperation">
      <input message="tns:MyRequest"/>
    </operation>
  </wsdl:portType>
  <wsdl:binding name="MyBinding" type="tns:MyPortType">
    <soap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
    <operation name="MyOperation">
      <soap:operation soapAction="urn:MyOperation"/>
    </operation>
  </wsdl:binding>
  <wsdl:service name="MyService">
    <port name="MyPort" binding="tns:MyBinding">
      <soap:address location="http://localhost/test"/>
    </port>
  </wsdl:service>
  <message name="MyRequest">
    <part name="param" type="xsd:string"/>
  </message>
</wsdl:definitions>
''';

      final definition = await parser.parseFromContent(mixedPrefixWsdl, 'mixed.wsdl');

      expect(definition.services, hasLength(1));
      expect(definition.services.first.name, equals('MyService'));
      expect(definition.services.first.ports.first.operations, hasLength(1));
      expect(definition.services.first.ports.first.operations.first.name, equals('MyOperation'));
    });

    test('should throw exception if wsdl:definitions is missing in non-SoapUI file', () async {
      const invalidXml = '<root><not-wsdl/></root>';
      
      expect(
        () => parser.parseFromContent(invalidXml, 'invalid.xml'),
        throwsA(predicate((e) => e.toString().contains('Elemento wsdl:definitions não encontrado na raiz'))),
      );
    });
  });
}
