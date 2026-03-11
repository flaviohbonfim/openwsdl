import 'dart:convert';
import '../../collections/models/collection_model.dart';

class CollectionExporter {
  static String exportToJson(Collection collection) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(collection.toJson());
  }

  static String exportToPostman(Collection collection) {
    final Map<String, dynamic> data = {
      "info": {
        "name": collection.name,
        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
      },
      "item": [
        ...collection.folders.map(_exportFolderToPostman),
        ...collection.requests.map(_exportRequestToPostman),
      ]
    };
    
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  static Map<String, dynamic> _exportFolderToPostman(Folder folder) {
    return {
      "name": folder.name,
      "item": [
        ...folder.folders.map(_exportFolderToPostman),
        ...folder.requests.map(_exportRequestToPostman),
      ]
    };
  }

  static Map<String, dynamic> _exportRequestToPostman(SavedRequest request) {
    final List<Map<String, String>> headers = [];
    request.headers.forEach((key, value) {
      headers.add({ "key": key, "value": value });
    });
    
    if (request.soapAction != null && !request.headers.containsKey('SOAPAction')) {
      headers.add({ "key": "SOAPAction", "value": request.soapAction! });
    }

    return {
      "name": request.name,
      "request": {
        "method": "POST",
        "header": headers,
        "body": {
          "mode": "raw",
          "raw": request.body
        },
        "url": {
          "raw": request.url
        }
      }
    };
  }
}
