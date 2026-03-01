class LogModel {
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;

  LogModel({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
  });

  // Untuk Tugas HOTS: Konversi Map (JSON) ke Object
  factory LogModel.fromMap(Map<String, dynamic> map) {
    final rawTimestamp = map['timestamp'];

    return LogModel(
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      timestamp: rawTimestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(rawTimestamp)
          : DateTime.parse(
              (rawTimestamp ?? DateTime.now().toIso8601String()) as String,
            ),
      category: (map['category'] ?? 'Pribadi') as String,
    );
  }

  // Konversi Object ke Map (JSON) untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
    };
  }
}
