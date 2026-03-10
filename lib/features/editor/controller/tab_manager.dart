import 'package:flutter/material.dart';
import 'tab_editor_state.dart';

/// Gerenciador de abas do editor
class TabManager extends ChangeNotifier {
  final List<TabEditorState> _tabs = [];
  int _activeTabIndex = -1;

  List<TabEditorState> get tabs => List.unmodifiable(_tabs);
  int get activeTabIndex => _activeTabIndex;
  
  TabEditorState? get activeTab {
    if (_activeTabIndex >= 0 && _activeTabIndex < _tabs.length) {
      return _tabs[_activeTabIndex];
    }
    return null;
  }

  void addTab({String? title, String? content, String? language}) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newTab = TabEditorState(
      id: newId,
      title: title ?? 'Nova Aba ${_tabs.length + 1}',
      content: content ?? '',
      language: language ?? 'xml',
    );
    _tabs.add(newTab);
    _activeTabIndex = _tabs.length - 1;
    notifyListeners();
  }

  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    
    _tabs.removeAt(index);
    
    if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    } else if (_activeTabIndex == index) {
      // Se fechou a ativa, a ativa agora é a mesma posição (que agora é o próximo item)
      // ou o anterior se era o último
      if (_tabs.isEmpty) _activeTabIndex = -1;
    } else if (_activeTabIndex > index) {
      _activeTabIndex--;
    }
    
    notifyListeners();
  }

  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  void updateActiveTabContent(String content, {bool isModified = true}) {
    if (activeTab != null) {
      activeTab!.content = content;
      activeTab!.isModified = isModified;
      notifyListeners();
    }
  }

  // Abre a aba inicial se estiver vazio
  void initIfEmpty() {
    if (_tabs.isEmpty) {
      addTab(title: 'Sem Título', content: '');
    }
  }
}
