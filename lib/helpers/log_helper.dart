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
      String color = _getColor(level);

      // 3. Output ke VS Code Debug Console (Non-blocking)
      dev.log(message, name: source, time: now, level: level * 100);

      // 4. Output ke Terminal (Agar Bapak bisa lihat di PC saat flutter run)
      // Format: [14:30:05] [INFO] [log_view.dart] -> Database Terhubung
      print('$color[$timestamp][$label][$source] -> $message\x1B[0m');

      // 5. Save to file: logs/dd-mm-yyyy.log
      await _writeToFile(now, source, label, message);
    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static Future<void> _writeToFile(
    DateTime now,
    String source,
    String label,
    String message,
  ) async {
    try {
      // Format nama file: dd-mm-yyyy.log
      String dateStr = DateFormat('dd-MM-yyyy').format(now);
      String timeStr = DateFormat('HH:mm:ss').format(now);

      // Buat folder logs di root project
      final Directory logsDir = Directory('logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // File log untuk tanggal ini
      final File logFile = File('logs/$dateStr.log');

      // Format log entry
      final logEntry = '[$timeStr][$label][$source] -> $message\n';

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

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // Merah
      case 2:
        return '\x1B[32m'; // Hijau
      case 3:
        return '\x1B[34m'; // Biru
      default:
        return '\x1B[0m';
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
    const color = '\x1B[32m'; // Hijau
    print('$color[$timestamp][SUCCESS][$source] -> $message\x1B[0m');
    dev.log(message, name: source, time: DateTime.now(), level: 200);
  }

  /// Log level WARNING (kuning) - untuk peringatan
  static void warning(String source, String message) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    const color = '\x1B[33m'; // Kuning
    print('$color[$timestamp][WARNING][$source] -> $message\x1B[0m');
    dev.log(message, name: source, time: DateTime.now(), level: 300);
  }

  /// Log level ERROR (merah) - untuk error dengan stack trace
  static void error(
    String source,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    const color = '\x1B[31m'; // Merah
    print('$color[$timestamp][ERROR][$source] -> $message');
    print('Error: $error');
    if (stackTrace != null) {
      print(
        'StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}\x1B[0m',
      );
    }
    dev.log(
      '$message\nError: $error',
      name: source,
      time: DateTime.now(),
      level: 1000,
      stackTrace: stackTrace,
    );
  }
}
