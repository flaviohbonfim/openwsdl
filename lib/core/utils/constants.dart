/// Constantes globais da aplicação
class AppConstants {
  // Versões SOAP
  static const String SOAP_1_1_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/';
  static const String SOAP_1_2_NAMESPACE = 'http://www.w3.org/2003/05/soap-envelope';
  
  // Headers HTTP
  static const String HEADER_CONTENT_TYPE = 'Content-Type';
  static const String HEADER_SOAP_ACTION = 'SOAPAction';
  
  // Content Types
  static const String CONTENT_TYPE_SOAP_1_1 = 'text/xml; charset=utf-8';
  static const String CONTENT_TYPE_SOAP_1_2 = 'application/soap+xml; charset=utf-8';
  
  // Chaves de Preferências
  static const String PREF_THEME = 'app_theme';
  static const String PREF_LAST_PROJECT = 'last_project';
  
  // Limites
  static const int MAX_TABS = 20;
  static const int MAX_HISTORY = 100;
  static const int REQUEST_TIMEOUT_MS = 30000;
}
