import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_001/helpers/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/services/access_control_service.dart';
import './models/log_model.dart';

class LogController {
  final String currentUserUid;
  final String currentUserRole;
  final String currentTeamId;
  bool _isSyncing = false;

  final ValueNotifier<List<LogModel>> _logsNotifier = ValueNotifier([]);
  ValueNotifier<List<LogModel>> get logs => _logsNotifier;

  Box<LogModel> get _offlineBox => Hive.box<LogModel>('offline_logs');
  final MongoService _mongoService = MongoService.instance;

  LogController({
    required this.currentUserUid,
    required this.currentUserRole,
    required this.currentTeamId,
  }) {
    _init();
  }

  Future<void> _init() async {
    await loadLogs();
  }

  Future<void> loadLogs() async {
    _logsNotifier.value = List<LogModel>.from(_offlineBox.values);
    unawaited(_syncPendingThenRefreshFromCloud());
  }

  Future<void> addLog(
    String title,
    String desc,
    String category,
    bool isPublic,
  ) async {
    try {
      final newLog = LogModel(
        title: title,
        description: desc,
        authorId: currentUserUid,
        date: DateTime.now(),
        teamId: currentTeamId,
        isPublic: isPublic,
      );

      final localIndex = await _offlineBox.add(newLog);
      _logsNotifier.value = List<LogModel>.from(_offlineBox.values);

      unawaited(_syncInsertToCloud(newLog, localIndex));
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal menambah log', e, stackTrace);
      throw Exception('Gagal menambah log: $e');
    }
  }

  Future<void> updateLog(
    LogModel oldLog,
    String title,
    String desc,
    String category,
    bool isPublic,
  ) async {
    try {
      final canUpdate = AccessControlService.canPerform(
        currentUserRole,
        AccessControlService.actionUpdate,
        isOwner: oldLog.authorId == currentUserUid,
      );

      if (!canUpdate) {
        await LogHelper.writeLog(
          'SECURITY BREACH: Unauthorized attempt',
          source: 'LogController',
          level: 1,
        );
        return;
      }

      final currentLogs = List<LogModel>.from(_logsNotifier.value);
      final updatedLog = LogModel(
        id: oldLog.id,
        authorId: oldLog.authorId,
        teamId: oldLog.teamId,
        date: oldLog.date,
        title: title,
        description: desc,
        category: oldLog.teamId,
        isPublic: isPublic,
      );

      var replaced = false;
      final updatedLogs = currentLogs.map((log) {
        if (!replaced && log.id == oldLog.id) {
          replaced = true;
          return updatedLog;
        }
        return log;
      }).toList();

      _logsNotifier.value = updatedLogs;

      await _offlineBox.clear();
      await _offlineBox.addAll(_logsNotifier.value);

      unawaited(_syncUpdateToCloud(updatedLog));
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal update log', e, stackTrace);
      throw Exception('Gagal update log: $e');
    }
  }

  Future<void> removeLog(LogModel targetLog) async {
    try {
      final canDelete = AccessControlService.canPerform(
        currentUserRole,
        AccessControlService.actionDelete,
        isOwner: targetLog.authorId == currentUserUid,
      );

      if (!canDelete) {
        await LogHelper.writeLog(
          'SECURITY BREACH: Unauthorized attempt',
          source: 'LogController',
          level: 1,
        );
        return;
      }

      final currentLogs = List<LogModel>.from(_logsNotifier.value);
      currentLogs.removeWhere((log) => log.id == targetLog.id);
      _logsNotifier.value = currentLogs;

      await _offlineBox.clear();
      await _offlineBox.addAll(_logsNotifier.value);

      unawaited(_syncDeleteFromCloud(targetLog));
    } catch (e, stackTrace) {
      LogHelper.error('LogController', 'Gagal menghapus log', e, stackTrace);
      throw Exception('Gagal menghapus log: $e');
    }
  }

  Future<void> _syncPendingThenRefreshFromCloud() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      if (!_mongoService.isConnected) {
        LogHelper.warning(
          'LogController',
          'OFFLINE: Menggunakan data cache lokal',
        );
        return;
      }

      final pendingEntries = <MapEntry<int, LogModel>>[];
      for (var index = 0; index < _offlineBox.length; index++) {
        final log = _offlineBox.getAt(index);
        if (log != null && log.id == null) {
          pendingEntries.add(MapEntry(index, log));
        }
      }

      var hasUploadFailure = false;
      for (final entry in pendingEntries) {
        try {
          final docWithId = await _mongoService.insertDocument(
            entry.value.toBson(),
          );
          final savedLog = LogModel.fromBson(docWithId);
          await _offlineBox.putAt(entry.key, savedLog);
        } catch (e) {
          hasUploadFailure = true;
          LogHelper.warning(
            'LogController',
            'WARNING: Data tersimpan lokal, akan sinkron saat online',
          );
        }
      }

      if (hasUploadFailure) {
        _logsNotifier.value = List<LogModel>.from(_offlineBox.values);
        return;
      }

      final documents = await _mongoService.getLogs(currentTeamId);
      final cloudLogs = documents.map((doc) => LogModel.fromBson(doc)).toList();

      await _offlineBox.clear();
      if (cloudLogs.isNotEmpty) {
        await _offlineBox.addAll(cloudLogs);
      }

      _logsNotifier.value = List<LogModel>.from(_offlineBox.values);
    } catch (_) {
      LogHelper.warning(
        'LogController',
        'OFFLINE: Menggunakan data cache lokal',
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncInsertToCloud(LogModel localLog, int localIndex) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final docWithId = await _mongoService.insertDocument(localLog.toBson());
      final savedLog = LogModel.fromBson(docWithId);
      if (localIndex >= 0 && localIndex < _offlineBox.length) {
        await _offlineBox.putAt(localIndex, savedLog);
        _logsNotifier.value = List<LogModel>.from(_offlineBox.values);
      }
    } catch (_) {
      LogHelper.warning(
        'LogController',
        'WARNING: Data tersimpan lokal, akan sinkron saat online',
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncUpdateToCloud(LogModel updatedLog) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      if (updatedLog.id != null) {
        await _mongoService.updateDocument(updatedLog.id!, updatedLog.toBson());
      } else {
        final docWithId = await _mongoService.insertDocument(
          updatedLog.toBson(),
        );
        final savedLog = LogModel.fromBson(docWithId);
        final currentLogs = List<LogModel>.from(_logsNotifier.value);
        var replaced = false;
        final mergedLogs = currentLogs.map((log) {
          if (!replaced && log.id == updatedLog.id) {
            replaced = true;
            return savedLog;
          }
          return log;
        }).toList();
        _logsNotifier.value = mergedLogs;
        await _offlineBox.clear();
        await _offlineBox.addAll(_logsNotifier.value);
      }
    } catch (_) {
      LogHelper.warning(
        'LogController',
        'WARNING: Data tersimpan lokal, akan sinkron saat online',
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncDeleteFromCloud(LogModel deletedLog) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      if (deletedLog.id == null) {
        return;
      }
      await _mongoService.deleteDocument(deletedLog.id!);
    } catch (_) {
      LogHelper.warning(
        'LogController',
        'WARNING: Data tersimpan lokal, akan sinkron saat online',
      );
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _logsNotifier.dispose();
  }
}
