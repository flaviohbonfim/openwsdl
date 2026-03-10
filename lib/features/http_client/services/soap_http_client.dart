import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/soap_response.dart';

class SoapHttpClient {
  final http.Client _client = http.Client();

  /// Envia uma requisição SOAP POST
  Future<SoapResponse> send({
    required String endpoint,
    required String xmlBody,
    String? soapAction,
    Map<String, String>? customHeaders,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final headers = {
        'Content-Type': 'text/xml; charset=utf-8',
        if (soapAction != null) 'SOAPAction': soapAction,
        ...?customHeaders,
      };

      // Log básico no console conforme solicitado 4.1
      print('>>> SOAP REQUEST INFO:');
      print('URL: $endpoint');
      print('Action: $soapAction');
      print('Headers: $headers');

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: utf8.encode(xmlBody),
      );

      stopwatch.stop();

      return SoapResponse(
        body: utf8.decode(response.bodyBytes),
        headers: response.headers,
        statusCode: response.statusCode,
        executionTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return SoapResponse.error(e.toString(), stopwatch.elapsed);
    }
  }

  void dispose() {
    _client.close();
  }
}
