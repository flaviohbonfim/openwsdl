import 'package:flutter/material.dart';
import '../../http_client/services/soap_http_client.dart';
import '../../http_client/models/soap_response.dart';
import 'package:openwsdl/core/utils/xml_utils.dart';
import 'tab_editor_state.dart';
import '../../environment/services/variable_interpolator.dart';
import '../../collections/models/collection_model.dart';
import '../../history/models/history_model.dart';
import '../../history/controller/history_provider.dart';

/// Gerenciador de abas do editor
class TabManager extends ChangeNotifier {
  final List<TabEditorState> _tabs = [];
  int _activeTabIndex = -1;
  final SoapHttpClient _client = SoapHttpClient();
  bool _isVerticalSplit = true;

  List<TabEditorState> get tabs => List.unmodifiable(_tabs);
  int get activeTabIndex => _activeTabIndex;
  bool get isVerticalSplit => _isVerticalSplit;

  void toggleLayout() {
    _isVerticalSplit = !_isVerticalSplit;
    notifyListeners();
  }

  TabEditorState? get activeTab {
    if (_activeTabIndex >= 0 && _activeTabIndex < _tabs.length) {
      return _tabs[_activeTabIndex];
    }
    return null;
  }

  void addTab({
    String? title,
    String? content,
    String? language,
    String? endpoint,
    String? soapAction,
    Map<String, String>? customHeaders,
    String? savedRequestId,
    String? collectionId,
    String? folderId,
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newTab = TabEditorState(
      id: newId,
      title: title ?? 'Nova Aba ${_tabs.length + 1}',
      content: content ?? '',
      language: language ?? 'xml',
      endpoint: endpoint,
      soapAction: soapAction,
      customHeaders: customHeaders ?? {},
      savedRequestId: savedRequestId,
      collectionId: collectionId,
      folderId: folderId,
    );
    _tabs.add(newTab);
    _activeTabIndex = _tabs.length - 1;
    notifyListeners();
  }

  void addSavedRequestTab(SavedRequest request, String collectionId, {String? folderId}) {
    addTab(
      title: request.name,
      content: request.body,
      endpoint: request.url,
      soapAction: request.soapAction,
      customHeaders: request.headers,
      savedRequestId: request.id,
      collectionId: collectionId,
      folderId: folderId,
    );
  }

  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs.removeAt(index);
    if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    } else if (_activeTabIndex == index) {
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

  void updateActiveTabUrl(String url) {
    if (activeTab != null) {
      activeTab!.endpoint = url;
      activeTab!.isModified = true;
      notifyListeners();
    }
  }

  void clearActiveTabModified() {
    if (activeTab != null) {
      activeTab!.isModified = false;
      notifyListeners();
    }
  }

  void initIfEmpty() {
    if (_tabs.isEmpty) {
      addTab(title: 'Sem Título', content: '');
    }
  }

  Future<void> executeSoapRequest({
    Map<String, String> variables = const {},
    HistoryProvider? historyProvider,
  }) async {
    final tab = activeTab;
    if (tab == null || tab.endpoint == null) return;

    final interpolatedEndpoint =
        VariableInterpolator.interpolate(tab.endpoint!, variables);
    final interpolatedBody =
        VariableInterpolator.interpolate(tab.content, variables);

    final Map<String, String> interpolatedHeaders = {};
    tab.customHeaders.forEach((key, value) {
      interpolatedHeaders[key] =
          VariableInterpolator.interpolate(value, variables);
    });

    if (!XmlUtils.isValidXml(interpolatedBody)) {
      tab.lastResponse = SoapResponse.error(
          'XML Inválido ou Malformado após interpolação', Duration.zero);
      notifyListeners();
      return;
    }

    tab.isExecuting = true;
    tab.lastResponse = null;
    notifyListeners();

    try {
      final response = await _client.send(
        endpoint: interpolatedEndpoint,
        xmlBody: interpolatedBody,
        soapAction: tab.soapAction,
        customHeaders: interpolatedHeaders,
      );
      tab.lastResponse = response;

      if (historyProvider != null) {
        historyProvider.addHistoryItem(HistoryItem(
          requestName: tab.title,
          url: interpolatedEndpoint,
          body: interpolatedBody,
          headers: interpolatedHeaders,
          soapAction: tab.soapAction,
          response: response,
          timestamp: DateTime.now(),
        ));
      }
    } finally {
      tab.isExecuting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }
}
