import 'package:flutter/foundation.dart';
import '../../../services/storage_service.dart';
import '../models/history_model.dart';

class HistoryProvider extends ChangeNotifier {
  final List<HistoryItem> _history = [];
  final StorageService _storageService = StorageService();
  static const int _maxItems = 100;

  List<HistoryItem> get history => _history;

  Future<void> loadHistory() async {
    final data = await _storageService.readJson('history.json');
    if (data != null && data is List) {
      _history.clear();
      for (var item in data) {
        _history.add(HistoryItem.fromJson(item));
      }
      _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    }
  }

  Future<void> saveHistory() async {
    final data = _history.map((h) => h.toJson()).toList();
    await _storageService.writeJson('history.json', data);
  }

  void addHistoryItem(HistoryItem item) {
    _history.insert(0, item);
    if (_history.length > _maxItems) {
      _history.removeLast();
    }
    saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    saveHistory();
    notifyListeners();
  }

  void deleteHistoryItem(String id) {
    _history.removeWhere((h) => h.id == id);
    saveHistory();
    notifyListeners();
  }
}
