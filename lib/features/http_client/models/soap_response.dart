class SoapResponse {
  final String body;
  final Map<String, String> headers;
  final int statusCode;
  final Duration executionTime;
  final String? error;

  SoapResponse({
    required this.body,
    required this.headers,
    required this.statusCode,
    required this.executionTime,
    this.error,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get hasError => error != null;

  factory SoapResponse.error(String message, Duration time) {
    return SoapResponse(
      body: '',
      headers: {},
      statusCode: 0,
      executionTime: time,
      error: message,
    );
  }
}
