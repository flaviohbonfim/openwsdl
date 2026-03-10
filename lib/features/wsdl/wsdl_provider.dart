import 'package:flutter/material.dart';
import 'package:soap_lite/features/wsdl/models/wsdl_definition.dart';
import 'package:soap_lite/features/wsdl/parser/wsdl_parser_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WsdlProvider with ChangeNotifier {
  final List<WsdlDefinition> _definitions = [];
  final WsdlParserService _parserService = WsdlParserService();
  bool _isLoading = false;

  List<WsdlDefinition> get definitions => List.unmodifiable(_definitions);
  bool get isLoading => _isLoading;

  WsdlProvider() {
    _loadFromPrefs();
  }

  Future<void> importWsdl(String url) async {
    // Evita duplicados
    if (_definitions.any((d) => d.sourceUrl == url)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final definition = await _parserService.parseFromUrl(url);
      definition.isLoaded = true;
      _definitions.add(definition);
      await _saveToPrefs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Carrega o conteúdo de um WSDL que foi apenas listado (persistido)
  Future<void> loadWsdl(WsdlDefinition definition) async {
    if (definition.isLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newDef = await _parserService.parseFromUrl(definition.sourceUrl);

      // Atualiza o objeto existente com os dados carregados
      final index = _definitions.indexOf(definition);
      if (index != -1) {
        newDef.isLoaded = true;
        _definitions[index] = newDef;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void removeWsdl(WsdlDefinition definition) {
    _definitions.remove(definition);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList('wsdl_urls') ?? [];

    _definitions.clear();
    for (final url in urls) {
      // Cria definições "placeholder" que serão carregadas sob demanda
      _definitions.add(WsdlDefinition(sourceUrl: url, isLoaded: false));
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final urls = _definitions.map((d) => d.sourceUrl).toList();
    await prefs.setStringList('wsdl_urls', urls);
  }
}
