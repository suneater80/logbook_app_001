import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final ObjectId? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String authorId;
  @HiveField(5)
  final String teamId;
  @HiveField(6)
  final bool isPublic;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    DateTime? date,
    String? authorId,
    String? teamId,
    bool? isPublic,
    DateTime? timestamp,
    String? category,
  }) : date = date ?? timestamp ?? DateTime.now(),
       authorId = authorId ?? '',
       teamId = teamId ?? category ?? '',
       isPublic = isPublic ?? false,
       assert(
         date == null || timestamp == null || date.isAtSameMomentAs(timestamp),
         'Provide only one of date or timestamp.',
       ),
       assert(
         teamId == null || category == null || teamId == category,
         'Provide only one of teamId or category.',
       );

  DateTime get timestamp => date;
  String get category => teamId;

  static String _parseString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

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
      date: _parseTimestamp(map['date'] ?? map['timestamp']),
      authorId: _parseString(map['authorId'] ?? map['author_id']),
      teamId: _parseString(
        map['teamId'] ?? map['category'],
        fallback: 'Pribadi',
      ),
      isPublic: (map['isPublic'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id?.oid,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'authorId': authorId,
      'teamId': teamId,
      'isPublic': isPublic,
      'timestamp': date.toIso8601String(),
      'category': teamId,
    };
  }

  // BSON/MongoDB mapping (Langkah Bridging)
  factory LogModel.fromBson(Map<String, dynamic> doc) {
    return LogModel(
      id: _parseObjectId(doc['_id']),
      title: (doc['title'] ?? '') as String,
      description: (doc['description'] ?? '') as String,
      date: _parseTimestamp(doc['date'] ?? doc['timestamp']),
      authorId: _parseString(doc['authorId'] ?? doc['author_id']),
      teamId: _parseString(
        doc['teamId'] ?? doc['category'],
        fallback: 'Pribadi',
      ),
      isPublic: (doc['isPublic'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toBson() {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'date': date,
      'authorId': authorId,
      'teamId': teamId,
      'isPublic': isPublic,
      'timestamp': date,
      'category': teamId,
    };

    if (id != null) {
      data['_id'] = id;
    }

    return data;
  }
}

class ObjectIdAdapter extends TypeAdapter<ObjectId> {
  @override
  final int typeId = 1;

  @override
  ObjectId read(BinaryReader reader) {
    return ObjectId.fromHexString(reader.readString());
  }

  @override
  void write(BinaryWriter writer, ObjectId obj) {
    writer.writeString(obj.oid);
  }
}
