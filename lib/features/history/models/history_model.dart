import 'package:uuid/uuid.dart';
import '../../http_client/models/soap_response.dart';

class HistoryItem {
  final String id;
  final String requestName;
  final String url;
  final String body;
  final Map<String, String> headers;
  final String? soapAction;
  final SoapResponse response;
  final DateTime timestamp;

  HistoryItem({
    String? id,
    required this.requestName,
    required this.url,
    required this.body,
    this.headers = const {},
    this.soapAction,
    required this.response,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestName': requestName,
    'url': url,
    'body': body,
    'headers': headers,
    'soapAction': soapAction,
    'response': {
      'body': response.body,
      'headers': response.headers,
      'statusCode': response.statusCode,
      'executionTime': response.executionTime.inMilliseconds,
      'error': response.error,
    },
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json['id'],
    requestName: json['requestName'],
    url: json['url'],
    body: json['body'],
    headers: Map<String, String>.from(json['headers'] ?? {}),
    soapAction: json['soapAction'],
    response: SoapResponse(
      body: json['response']['body'] ?? '',
      headers: Map<String, String>.from(json['response']['headers'] ?? {}),
      statusCode: json['response']['statusCode'] ?? 200,
      executionTime: Duration(milliseconds: json['response']['executionTime'] ?? 0),
      error: json['response']['error'],
    ),
    timestamp: DateTime.parse(json['timestamp']),
  );
}
