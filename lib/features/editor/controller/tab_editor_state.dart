import 'package:flutter/foundation.dart';

/// Representa o estado de uma aba no editor (Renomeado para evitar conflito com flutter_monaco)
class TabEditorState {
  final String id;
  String title;
  String content;
  bool isModified;
  String? language; // Mantemos como string no modelo e convertemos no widget

  TabEditorState({
    required this.id,
    this.title = 'Sem Título',
    this.content = '',
    this.isModified = false,
    this.language = 'xml',
  });

  TabEditorState copyWith({
    String? id,
    String? title,
    String? content,
    bool? isModified,
    String? language,
  }) {
    return TabEditorState(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isModified: isModified ?? this.isModified,
      language: language ?? this.language,
    );
  }
}
