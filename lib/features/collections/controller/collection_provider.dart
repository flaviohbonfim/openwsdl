import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../../../services/storage_service.dart';
import '../models/collection_model.dart';

class CollectionProvider extends ChangeNotifier {
  final List<Collection> _collections = [];
  final StorageService _storageService = StorageService();

  List<Collection> get collections => _collections;

  Future<void> loadCollections() async {
    final data = await _storageService.readJson('collections.json');
    if (data != null && data is List) {
      _collections.clear();
      for (var item in data) {
        _collections.add(Collection.fromJson(item));
      }
      notifyListeners();
    }
  }

  Future<void> saveCollections() async {
    final data = _collections.map((c) => c.toJson()).toList();
    await _storageService.writeJson('collections.json', data);
  }

  void addCollection(String name) {
    _collections.add(Collection(name: name));
    saveCollections();
    notifyListeners();
  }

  void addCollectionFromModel(Collection collection) {
    _collections.add(collection);
    saveCollections();
    notifyListeners();
  }

  void addFolder(String collectionId, String name, {String? parentFolderId}) {
    final collection = _collections.firstWhereOrNull((c) => c.id == collectionId);
    if (collection == null) return;

    if (parentFolderId == null) {
      collection.folders.add(Folder(name: name));
    } else {
      final parentFolder = _findFolder(collection.folders, parentFolderId);
      parentFolder?.folders.add(Folder(name: name));
    }
    saveCollections();
    notifyListeners();
  }

  void addSavedRequest(String collectionId, SavedRequest request, {String? folderId}) {
    final collection = _collections.firstWhereOrNull((c) => c.id == collectionId);
    if (collection == null) return;

    if (folderId == null) {
      collection.requests.add(request);
    } else {
      final folder = _findFolder(collection.folders, folderId);
      folder?.requests.add(request);
    }
    saveCollections();
    notifyListeners();
  }

  Folder? _findFolder(List<Folder> folders, String folderId) {
    for (var folder in folders) {
      if (folder.id == folderId) return folder;
      final found = _findFolder(folder.folders, folderId);
      if (found != null) return found;
    }
    return null;
  }

  void deleteCollection(String id) {
    _collections.removeWhere((c) => c.id == id);
    saveCollections();
    notifyListeners();
  }

  void deleteFolder(String collectionId, String folderId) {
    final collection = _collections.firstWhereOrNull((c) => c.id == collectionId);
    if (collection == null) return;

    _deleteFolderRecursive(collection.folders, folderId);
    saveCollections();
    notifyListeners();
  }

  void _deleteFolderRecursive(List<Folder> folders, String folderId) {
    final initialLength = folders.length;
    folders.removeWhere((f) => f.id == folderId);
    if (folders.length == initialLength) {
      for (var folder in folders) {
        _deleteFolderRecursive(folder.folders, folderId);
      }
    }
  }

  void deleteRequest(String collectionId, String requestId, {String? folderId}) {
    final collection = _collections.firstWhereOrNull((c) => c.id == collectionId);
    if (collection == null) return;

    if (folderId == null) {
      collection.requests.removeWhere((r) => r.id == requestId);
    } else {
      final folder = _findFolder(collection.folders, folderId);
      folder?.requests.removeWhere((r) => r.id == requestId);
    }
    saveCollections();
    notifyListeners();
  }
}
