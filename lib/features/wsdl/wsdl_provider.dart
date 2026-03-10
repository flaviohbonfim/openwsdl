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
    _isLoading = true;
    notifyListeners();

    try {
      final definition = await _parserService.parseFromUrl(url);
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

  void removeWsdl(WsdlDefinition definition) {
    _definitions.remove(definition);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList('wsdl_urls') ?? [];

    for (final url in urls) {
      try {
        final definition = await _parserService.parseFromUrl(url);
        _definitions.add(definition);
      } catch (e) {
        print('Erro ao carregar WSDL persistido ($url): $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final urls = _definitions.map((d) => d.sourceUrl).toList();
    await prefs.setStringList('wsdl_urls', urls);
  }
}
