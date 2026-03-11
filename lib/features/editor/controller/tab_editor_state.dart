import '../../http_client/models/soap_response.dart';

/// Representa o estado de uma aba no editor
class TabEditorState {
  final String id;
  String title;
  String content;
  bool isModified;
  String? language;

  // Atributos de execução
  String? endpoint;
  String? soapAction;
  Map<String, String> customHeaders;
  SoapResponse? lastResponse;
  bool isExecuting;
  
  // Persistência e Origem
  String? savedRequestId;
  String? collectionId; // ID da coleção de origem
  String? folderId;     // ID da pasta de origem (opcional)

  TabEditorState({
    required this.id,
    this.title = 'Sem Título',
    this.content = '',
    this.isModified = false,
    this.language = 'xml',
    this.endpoint,
    this.soapAction,
    Map<String, String>? customHeaders,
    this.lastResponse,
    this.isExecuting = false,
    this.savedRequestId,
    this.collectionId,
    this.folderId,
  }) : customHeaders = customHeaders ?? {};

  TabEditorState copyWith({
    String? id,
    String? title,
    String? content,
    bool? isModified,
    String? language,
    String? endpoint,
    String? soapAction,
    Map<String, String>? customHeaders,
    SoapResponse? lastResponse,
    bool? isExecuting,
    String? savedRequestId,
    String? collectionId,
    String? folderId,
  }) {
    return TabEditorState(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isModified: isModified ?? this.isModified,
      language: language ?? this.language,
      endpoint: endpoint ?? this.endpoint,
      soapAction: soapAction ?? this.soapAction,
      customHeaders: customHeaders ?? this.customHeaders,
      lastResponse: lastResponse ?? this.lastResponse,
      isExecuting: isExecuting ?? this.isExecuting,
      savedRequestId: savedRequestId ?? this.savedRequestId,
      collectionId: collectionId ?? this.collectionId,
      folderId: folderId ?? this.folderId,
    );
  }
}
