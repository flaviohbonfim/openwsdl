import 'dart:convert';
import '../../collections/models/collection_model.dart';

class PostmanImporter {
  static Collection import(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final String name = data['info']?['name'] ?? 'Imported Postman Collection';
    
    final collection = Collection(name: name);
    
    if (data['item'] != null && data['item'] is List) {
      _parseItems(data['item'], collection.folders, collection.requests);
    }
    
    return collection;
  }

  static void _parseItems(List items, List<Folder> folders, List<SavedRequest> requests) {
    for (var item in items) {
      if (item['item'] != null) {
        // It's a folder
        final folder = Folder(name: item['name'] ?? 'Untitled Folder');
        folders.add(folder);
        _parseItems(item['item'], folder.folders, folder.requests);
      } else if (item['request'] != null) {
        // It's a request
        final req = item['request'];
        
        final Map<String, String> headers = {};
        if (req['header'] != null && req['header'] is List) {
          for (var h in req['header']) {
            headers[h['key']] = h['value'];
          }
        }

        String body = '';
        if (req['body'] != null && req['body']['raw'] != null) {
          body = req['body']['raw'];
        }

        String url = '';
        if (req['url'] != null) {
          if (req['url'] is String) {
            url = req['url'];
          } else if (req['url']['raw'] != null) {
            url = req['url']['raw'];
          }
        }

        requests.add(SavedRequest(
          name: item['name'] ?? 'Untitled Request',
          url: url,
          body: body,
          headers: headers,
          soapAction: headers['SOAPAction'],
        ));
      }
    }
  }
}
