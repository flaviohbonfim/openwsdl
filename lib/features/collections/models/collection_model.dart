import 'package:uuid/uuid.dart';

class SavedRequest {
  final String id;
  String name;
  String method;
  String url;
  String body;
  Map<String, String> headers;
  String? soapAction;

  SavedRequest({
    String? id,
    required this.name,
    this.method = 'POST',
    required this.url,
    required this.body,
    this.headers = const {},
    this.soapAction,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'method': method,
    'url': url,
    'body': body,
    'headers': headers,
    'soapAction': soapAction,
  };

  factory SavedRequest.fromJson(Map<String, dynamic> json) => SavedRequest(
    id: json['id'],
    name: json['name'],
    method: json['method'] ?? 'POST',
    url: json['url'],
    body: json['body'],
    headers: Map<String, String>.from(json['headers'] ?? {}),
    soapAction: json['soapAction'],
  );
}

class Folder {
  final String id;
  String name;
  List<Folder> folders;
  List<SavedRequest> requests;

  Folder({
    String? id,
    required this.name,
    List<Folder>? folders,
    List<SavedRequest>? requests,
  })  : id = id ?? const Uuid().v4(),
        folders = folders ?? [],
        requests = requests ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'folders': folders.map((f) => f.toJson()).toList(),
    'requests': requests.map((r) => r.toJson()).toList(),
  };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'],
    name: json['name'],
    folders: (json['folders'] as List?)?.map((f) => Folder.fromJson(f)).toList() ?? [],
    requests: (json['requests'] as List?)?.map((r) => SavedRequest.fromJson(r)).toList() ?? [],
  );
}

class Collection {
  final String id;
  String name;
  List<Folder> folders;
  List<SavedRequest> requests;

  Collection({
    String? id,
    required this.name,
    List<Folder>? folders,
    List<SavedRequest>? requests,
  })  : id = id ?? const Uuid().v4(),
        folders = folders ?? [],
        requests = requests ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'folders': folders.map((f) => f.toJson()).toList(),
    'requests': requests.map((r) => r.toJson()).toList(),
  };

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    id: json['id'],
    name: json['name'],
    folders: (json['folders'] as List?)?.map((f) => Folder.fromJson(f)).toList() ?? [],
    requests: (json['requests'] as List?)?.map((r) => SavedRequest.fromJson(r)).toList() ?? [],
  );
}
