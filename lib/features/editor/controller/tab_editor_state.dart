import 'package:flutter/foundation.dart';
import '../../http_client/models/soap_response.dart';

/// Representa o estado de uma aba no editor (Renomeado para evitar conflito com flutter_monaco)
class TabEditorState {
  final String id;
  String title;
  String content;
  bool isModified;
  String? language; // Mantemos como string no modelo e convertemos no widget

  // Atributos de execução (Fase 4)
  String? endpoint;
  String? soapAction;
  Map<String, String> customHeaders;
  SoapResponse? lastResponse;
  bool isExecuting;
  String? savedRequestId; // ID da requisição se ela vier de uma coleção

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
    );
  }
}
