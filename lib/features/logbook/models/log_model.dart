import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class LogModel {
  final ObjectId? id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
  });

  static ObjectId? _parseObjectId(dynamic value) {
    if (value == null) return null;
    if (value is ObjectId) return value;
    if (value is String && value.length == 24) {
      try {
        return ObjectId.fromHexString(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static DateTime _parseTimestamp(dynamic rawTimestamp) {
    if (rawTimestamp is DateTime) return rawTimestamp;
    if (rawTimestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    }
    if (rawTimestamp is String) {
      return DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // JSON/local storage mapping (tetap dipakai oleh controller lama)
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: _parseObjectId(map['id'] ?? map['_id']),
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      timestamp: _parseTimestamp(map['timestamp']),
      category: (map['category'] ?? 'Pribadi') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id?.toHexString(),
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }

  // BSON/MongoDB mapping (Langkah Bridging)
  factory LogModel.fromBson(Map<String, dynamic> doc) {
    return LogModel(
      id: _parseObjectId(doc['_id']),
      title: (doc['title'] ?? '') as String,
      description: (doc['description'] ?? '') as String,
      timestamp: _parseTimestamp(doc['timestamp']),
      category: (doc['category'] ?? 'Pribadi') as String,
    );
  }

  Map<String, dynamic> toBson() {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'timestamp': timestamp, // simpan DateTime langsung untuk BSON
      'category': category,
    };

    if (id != null) {
      data['_id'] = id;
    }

    return data;
  }
}