import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> _logsNotifier = ValueNotifier([]);
  ValueNotifier<List<LogModel>> get logs => _logsNotifier;

  static const String _storageKey = 'user_logs_data';

  LogController() {
    _init();
  }

  Future<void> _init() async {
    await loadFromDisk();
  }

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title,
      description: desc,
      timestamp: DateTime.now(),
      category: category,
    );
    _logsNotifier.value = [..._logsNotifier.value, newLog];
    saveToDisk();
  }

  void updateLog(int index, String title, String desc, String category) {
    final currentLogs = List<LogModel>.from(_logsNotifier.value);
    if (index < 0 || index >= currentLogs.length) return;

    currentLogs[index] = LogModel(
      title: title,
      description: desc,
      timestamp: DateTime.now(),
      category: category,
    );
    _logsNotifier.value = currentLogs;
    saveToDisk();
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(_logsNotifier.value);
    if (index < 0 || index >= currentLogs.length) return;

    currentLogs.removeAt(index);
    _logsNotifier.value = currentLogs;
    saveToDisk();
  }

  String _encodeLogsToJson(List<LogModel> logs) {
    return jsonEncode(logs.map((log) => log.toMap()).toList());
  }

  List<LogModel> _decodeLogsFromJson(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => LogModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = _encodeLogsToJson(_logsNotifier.value);
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null || data.isEmpty) {
      _logsNotifier.value = [];
      return;
    }

    try {
      _logsNotifier.value = _decodeLogsFromJson(data);
    } on FormatException {
      _logsNotifier.value = [];
      await prefs.remove(_storageKey);
    } on TypeError {
      _logsNotifier.value = [];
      await prefs.remove(_storageKey);
    }
  }

  void dispose() {
    _logsNotifier.dispose();
  }
}
