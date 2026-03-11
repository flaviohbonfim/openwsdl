import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class StorageService {
  late SharedPreferences _prefs;
  
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- SharedPreferences (UI Configs) ---

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // --- File System (Collections, History) ---

  Future<Directory> getAppDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final appDir = Directory(p.join(docs.path, 'SOAP-Lite'));
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<File> getFile(String fileName) async {
    final appDir = await getAppDirectory();
    return File(p.join(appDir.path, fileName));
  }

  Future<void> writeJson(String fileName, dynamic data) async {
    final file = await getFile(fileName);
    final encoder = const JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(data);
    await file.writeAsString(jsonString);
  }

  Future<dynamic> readJson(String fileName) async {
    try {
      final file = await getFile(fileName);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString);
      }
    } catch (e) {
      print('Error reading JSON file $fileName: $e');
    }
    return null;
  }
}
