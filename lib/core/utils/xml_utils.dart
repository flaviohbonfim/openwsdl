import 'package:xml/xml.dart';

class XmlUtils {
  /// Retorna o XML formatado com indentação
  static String prettyPrint(String xmlString) {
    if (xmlString.isEmpty) return '';
    try {
      final document = XmlDocument.parse(xmlString);
      return document.toXmlString(pretty: true, indent: '  ');
    } catch (e) {
      // Se falhar o parse, retorna o original
      return xmlString;
    }
  }

  /// Tenta validar se o XML é básico (tags de abertura e fechamento)
  static bool isValidXml(String xmlString) {
    if (xmlString.isEmpty) return false;
    try {
      XmlDocument.parse(xmlString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
