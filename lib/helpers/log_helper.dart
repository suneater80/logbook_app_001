import 'dart:developer' as dev;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown", // Menandakan file/proses asal
    int level = 2,
  }) async {
    // 1. Filter Konfigurasi (ENV)
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      final now = DateTime.now();

      // 2. Format Waktu untuk Konsol
      String timestamp = DateFormat('HH:mm:ss').format(now);
      String label = _getLabel(level);

      // 3. Output ke VS Code Debug Console (Non-blocking)
      dev.log(message, name: source, time: now, level: level * 100);

      // 4. Format human-readable untuk tersimpan rapi di file log
      final formattedMessage = '[$timestamp][$label][$source] -> $message';

      // 5. Save to file: logs/dd-mm-yyyy.log
      await _writeToFile(now, formattedMessage);
    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static Future<void> _writeToFile(DateTime now, String message) async {
    try {
      // Format nama file: dd-mm-yyyy.log
      String dateStr = DateFormat('dd-MM-yyyy').format(now);
      // Buat folder logs di root project
      final Directory logsDir = Directory('logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // File log untuk tanggal ini
      final File logFile = File('logs/$dateStr.log');

      // Format log entry
      final logEntry = '$message\n';

      // Append ke file (create if not exists)
      await logFile.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      // Silent fail untuk file logging, jangan ganggu aplikasi
      dev.log("File logging failed: $e", name: "LogHelper", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  // === Smart Logging Shortcuts untuk MongoDB Integration ===

  /// Log level INFO (hijau) - untuk informasi umum
  static void info(String source, String message) {
    writeLog(message, source: source, level: 2);
  }

  /// Log level SUCCESS (hijau terang) - untuk operasi berhasil
  static void success(String source, String message) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    dev.log(message, name: source, time: DateTime.now(), level: 200);
    _writeToFile(DateTime.now(), '[$timestamp][SUCCESS][$source] -> $message');
  }

  /// Log level WARNING (kuning) - untuk peringatan
  static void warning(String source, String message) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    dev.log(message, name: source, time: DateTime.now(), level: 300);
    _writeToFile(DateTime.now(), '[$timestamp][WARNING][$source] -> $message');
  }

  /// Log level ERROR (merah) - untuk error dengan stack trace
  static void error(
    String source,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    final stackPreview = stackTrace == null
        ? ''
        : '\nStackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}';
    final fullMessage =
        '[$timestamp][ERROR][$source] -> $message\nError: $error$stackPreview';
    dev.log(
      fullMessage,
      name: source,
      time: DateTime.now(),
      level: 1000,
      stackTrace: stackTrace,
    );
    _writeToFile(DateTime.now(), fullMessage);
  }
}
