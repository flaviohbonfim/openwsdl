import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/environment_model.dart';

class EnvironmentProvider extends ChangeNotifier {
  static const String _storageKey = 'soap_lite_environments';
  static const String _activeIdKey = 'soap_lite_active_environment_id';
  static const _uuid = Uuid();

  List<Environment> _environments = [];
  String? _activeEnvironmentId;
  bool _isLoading = true;

  EnvironmentProvider() {
    _loadFromStorage();
  }

  List<Environment> get environments => _environments;
  String? get activeEnvironmentId => _activeEnvironmentId;
  bool get isLoading => _isLoading;

  Environment? get activeEnvironment {
    if (_activeEnvironmentId == null) return null;
    return _environments.where((e) => e.id == _activeEnvironmentId).firstOrNull;
  }

  /// Returns a map of all variables in the active environment.
  Map<String, String> getActiveVariables() {
    final env = activeEnvironment;
    if (env == null) return {};
    
    return {
      for (var v in env.variables) if (v.enabled) v.key: v.value
    };
  }

  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final envsJson = prefs.getString(_storageKey);
      _activeEnvironmentId = prefs.getString(_activeIdKey);

      if (envsJson != null) {
        final List<dynamic> decoded = json.decode(envsJson);
        _environments = decoded.map((item) => Environment.fromMap(item)).toList();
      }

      // Ensure at least one environment exists
      if (_environments.isEmpty) {
        await createEnvironment('Default');
      }

      // Ensure active ID is valid
      if (_activeEnvironmentId != null && !_environments.any((e) => e.id == _activeEnvironmentId)) {
        _activeEnvironmentId = _environments.first.id;
      } else if (_activeEnvironmentId == null && _environments.isNotEmpty) {
        _activeEnvironmentId = _environments.first.id;
      }
    } catch (e) {
      debugPrint('Error loading environments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final envsJson = json.encode(_environments.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, envsJson);
      
      if (_activeEnvironmentId != null) {
        await prefs.setString(_activeIdKey, _activeEnvironmentId!);
      }
    } catch (e) {
      debugPrint('Error saving environments: $e');
    }
  }

  Future<void> createEnvironment(String name) async {
    final newEnv = Environment(
      id: _uuid.v4(),
      name: name,
      variables: [],
    );
    _environments.add(newEnv);
    if (_activeEnvironmentId == null) {
      _activeEnvironmentId = newEnv.id;
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> updateEnvironment(Environment env) async {
    final index = _environments.indexWhere((e) => e.id == env.id);
    if (index != -1) {
      _environments[index] = env;
      await _saveToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteEnvironment(String id) async {
    if (_environments.length <= 1) return; // Keep at least one

    _environments.removeWhere((e) => e.id == id);
    if (_activeEnvironmentId == id) {
      _activeEnvironmentId = _environments.first.id;
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> setActiveEnvironment(String? id) async {
    _activeEnvironmentId = id;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> duplicateEnvironment(String id) async {
    final original = _environments.where((e) => e.id == id).firstOrNull;
    if (original == null) return;

    final duplicate = Environment(
      id: _uuid.v4(),
      name: '${original.name} (Copy)',
      variables: List.from(original.variables),
    );
    
    _environments.add(duplicate);
    await _saveToStorage();
    notifyListeners();
  }
}
