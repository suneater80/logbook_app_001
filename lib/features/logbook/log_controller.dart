import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_001/helpers/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import './models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> _logsNotifier = ValueNotifier([]);
  ValueNotifier<List<LogModel>> get logs => _logsNotifier;

  static const String _storageKey = 'user_logs_data';
  static const String _pendingSyncKey =
      'pending_sync_logs'; // NEW: Untuk track data offline
  final MongoService _mongoService = MongoService.instance;

  LogController() {
    _init();
  }

  Future<void> _init() async {
    // Coba load dari cloud terlebih dahulu
    if (_mongoService.isConnected) {
      await loadFromCloud();
      // Auto-sync data offline ke cloud
      await _syncPendingToCloud();
    } else {
      // Fallback ke local storage
      LogHelper.warning(
        'LogController',
        'MongoDB tidak terhubung, menggunakan local storage',
      );
      await loadFromDisk();
    }
  }

  Future<void> addLog(String title, String desc, String category) async {
    try {
      final newLog = LogModel(
        title: title,
        description: desc,
        timestamp: DateTime.now(),
        category: category,
      );

      if (_mongoService.isConnected) {
        // Simpan ke cloud
        final docWithId = await _mongoService.insertDocument(newLog.toBson());
        final savedLog = LogModel.fromBson(docWithId);
        _logsNotifier.value = [..._logsNotifier.value, savedLog];

        // Tetap backup ke local
        await saveToDisk();

        LogHelper.success('LogController', 'Log berhasil disimpan ke cloud');
      } else {
        // Fallback ke local + tandai untuk sync nanti
        _logsNotifier.value = [..._logsNotifier.value, newLog];
        await saveToDisk();
        await _savePendingSync(newLog); // Mark untuk auto-sync nanti

        LogHelper.warning(
          'LogController',
          'Log disimpan lokal & akan di-sync saat online',
        );
      }
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal menambah log', e, stackTrace);
      throw Exception('Gagal menambah log: $e');
    }
  }

  Future<void> updateLog(
    int index,
    String title,
    String desc,
    String category,
  ) async {
    try {
      final currentLogs = List<LogModel>.from(_logsNotifier.value);
      if (index < 0 || index >= currentLogs.length) return;

      final existingLog = currentLogs[index];
      final updatedLog = LogModel(
        id: existingLog.id,
        title: title,
        description: desc,
        timestamp: DateTime.now(),
        category: category,
      );

      if (_mongoService.isConnected && existingLog.id != null) {
        // Update di cloud
        await _mongoService.updateDocument(
          existingLog.id!,
          updatedLog.toBson(),
        );
        currentLogs[index] = updatedLog;
        _logsNotifier.value = currentLogs;

        // Backup ke local
        await saveToDisk();

        LogHelper.success('LogController', 'Log berhasil diupdate di cloud');
      } else {
        // Fallback ke local
        currentLogs[index] = updatedLog;
        _logsNotifier.value = currentLogs;
        await saveToDisk();
        LogHelper.warning(
          'LogController',
          'Log diupdate di local storage (offline)',
        );
      }
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal update log', e, stackTrace);
      throw Exception('Gagal update log: $e');
    }
  }

  Future<void> removeLog(int index) async {
    try {
      final currentLogs = List<LogModel>.from(_logsNotifier.value);
      if (index < 0 || index >= currentLogs.length) return;

      final logToDelete = currentLogs[index];

      if (_mongoService.isConnected && logToDelete.id != null) {
        // Hapus dari cloud
        await _mongoService.deleteDocument(logToDelete.id!);
        currentLogs.removeAt(index);
        _logsNotifier.value = currentLogs;

        // Backup ke local
        await saveToDisk();

        LogHelper.success('LogController', 'Log berhasil dihapus dari cloud');
      } else {
        // Fallback ke local
        currentLogs.removeAt(index);
        _logsNotifier.value = currentLogs;
        await saveToDisk();
        LogHelper.warning(
          'LogController',
          'Log dihapus dari local storage (offline)',
        );
      }
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal menghapus log', e, stackTrace);
      throw Exception('Gagal menghapus log: $e');
    }
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
      LogHelper.info(
        'LogController',
        'Berhasil load ${_logsNotifier.value.length} log dari disk',
      );
    } on FormatException {
      _logsNotifier.value = [];
      await prefs.remove(_storageKey);
    } on TypeError {
      _logsNotifier.value = [];
      await prefs.remove(_storageKey);
    }
  }

  // Load data dari MongoDB Cloud
  Future<void> loadFromCloud() async {
    try {
      LogHelper.info('LogController', 'Memuat data dari cloud...');

      final documents = await _mongoService.getAllDocuments();
      final logs = documents.map((doc) => LogModel.fromBson(doc)).toList();

      _logsNotifier.value = logs;
      LogHelper.success(
        'LogController',
        'Berhasil load ${logs.length} log dari cloud',
      );

      // Backup ke local storage
      await saveToDisk();
    } catch (e, stackTrace) {
      LogHelper.error(
        'LogController',
        'Gagal load dari cloud, fallback ke local',
        e,
        stackTrace,
      );
      await loadFromDisk();
    }
  }

  // Method untuk refresh data dari cloud (untuk pull-to-refresh)
  Future<void> refreshFromCloud() async {
    if (_mongoService.isConnected) {
      await loadFromCloud();
      // Setelah online, sync data pending
      await _syncPendingToCloud();
    } else {
      LogHelper.warning(
        'LogController',
        'Tidak dapat refresh: MongoDB tidak terhubung',
      );
      throw Exception('MongoDB tidak terhubung');
    }
  }

  // === SYNC MECHANISM: Auto-upload data offline ke cloud ===

  /// Simpan data yang belum ter-sync ke cloud (dibuat saat offline)
  Future<void> _savePendingSync(LogModel log) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existingData = prefs.getString(_pendingSyncKey);

      List<Map<String, dynamic>> pendingList = [];
      if (existingData != null && existingData.isNotEmpty) {
        final decoded = jsonDecode(existingData) as List<dynamic>;
        pendingList = decoded.map((e) => e as Map<String, dynamic>).toList();
      }

      pendingList.add(log.toMap());
      await prefs.setString(_pendingSyncKey, jsonEncode(pendingList));

      LogHelper.info(
        'LogController',
        'Data ditandai untuk sync ke cloud nanti',
      );
    } catch (e) {
      LogHelper.warning('LogController', 'Gagal menyimpan pending sync: $e');
    }
  }

  /// Upload semua data pending ke cloud saat online
  Future<void> _syncPendingToCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? pendingData = prefs.getString(_pendingSyncKey);

      if (pendingData == null || pendingData.isEmpty) {
        return; // Tidak ada data pending
      }

      final decoded = jsonDecode(pendingData) as List<dynamic>;
      final pendingLogs = decoded
          .map((e) => LogModel.fromMap(e as Map<String, dynamic>))
          .toList();

      if (pendingLogs.isEmpty) return;

      LogHelper.info(
        'LogController',
        'Syncing ${pendingLogs.length} data offline ke cloud...',
      );

      int syncCount = 0;
      for (final log in pendingLogs) {
        try {
          await _mongoService.insertDocument(log.toBson());
          syncCount++;
        } catch (e) {
          LogHelper.error(
            'LogController',
            'Gagal sync log: ${log.title}',
            e,
            null,
          );
        }
      }

      // Hapus pending list setelah sync
      await prefs.remove(_pendingSyncKey);

      LogHelper.success(
        'LogController',
        'Berhasil sync $syncCount dari ${pendingLogs.length} data ke cloud',
      );

      // Refresh data dari cloud untuk sinkronisasi lengkap
      await loadFromCloud();
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal melakukan sync', e, stackTrace);
    }
  }

  /// Public method untuk manual sync (bisa dipanggil dari UI)
  Future<int> syncToCloud() async {
    if (!_mongoService.isConnected) {
      throw Exception('Tidak dapat sync: MongoDB tidak terhubung');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? pendingData = prefs.getString(_pendingSyncKey);

      if (pendingData == null || pendingData.isEmpty) {
        return 0; // Tidak ada data untuk di-sync
      }

      final decoded = jsonDecode(pendingData) as List<dynamic>;
      final count = decoded.length;

      await _syncPendingToCloud();
      return count;
    } catch (e) {
      LogHelper.error('LogController', 'Gagal sync manual', e, null);
      rethrow;
    }
  }

  void dispose() {
    _logsNotifier.dispose();
  }
}
