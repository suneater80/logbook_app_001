import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;
import 'log_helper.dart';

class MongoService {
  static MongoService? _instance;
  static Db? _db;
  static DbCollection? _collection;

  MongoService._();

  static MongoService get instance {
    _instance ??= MongoService._();
    return _instance!;
  }

  bool get isConnected => _db != null && _db!.isConnected;

  DbCollection get collection {
    if (_collection == null) {
      throw Exception(
        'MongoDB belum diinisialisasi. Panggil init() terlebih dahulu.',
      );
    }
    return _collection!;
  }

  Future<void> init() async {
    return connect();
  }

  Future<void> connect() async {
    if (isConnected) {
      LogHelper.info(
        'MongoDB',
        'Sudah terhubung. Tidak perlu inisialisasi ulang.',
      );
      dev.log(
        '[MongoService.connect] Skip connect karena status already connected.',
        name: 'MongoDB',
        level: 300,
      );
      return;
    }

    try {
      final mongoUrl = dotenv.env['MONGO_URL'];
      final dbName = dotenv.env['DB_NAME'] ?? 'logbook_db';
      final collectionName = dotenv.env['COLLECTION_NAME'] ?? 'logs';

      if (mongoUrl == null || mongoUrl.isEmpty) {
        throw Exception('MONGO_URL tidak ditemukan di file .env');
      }

      LogHelper.info('MongoDB', 'Mencoba koneksi ke: $mongoUrl');
      dev.log(
        '[MongoService.connect] Sebelum Db.create(), dbName=$dbName, collectionName=$collectionName',
        name: 'MongoDB',
        level: 300,
      );

      _db = await Db.create(mongoUrl);
      dev.log(
        '[MongoService.connect] Db.create() selesai. Sebelum db.open()',
        name: 'MongoDB',
        level: 300,
      );

      await _db!.open();
      dev.log(
        '[MongoService.connect] db.open() selesai. isConnected=${_db!.isConnected}',
        name: 'MongoDB',
        level: 300,
      );

      _collection = _db!.collection(collectionName);
      dev.log(
        '[MongoService.connect] Collection binding selesai untuk: $collectionName',
        name: 'MongoDB',
        level: 300,
      );

      LogHelper.success(
        'MongoDB',
        'Berhasil terhubung ke database: $dbName, collection: $collectionName',
      );
    } catch (e, stackTrace) {
      dev.log(
        '[MongoService.connect] Exception saat koneksi: $e',
        name: 'MongoDB',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      LogHelper.error('MongoDB', 'Gagal koneksi', e, stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      LogHelper.info('MongoDB', 'Koneksi ditutup');
    }
  }

  // CRUD Operations dengan Smart Logging

  Future<Map<String, dynamic>> insertDocument(
    Map<String, dynamic> document,
  ) async {
    try {
      LogHelper.info('MongoDB', 'Insert document: ${document['title']}');

      final result = await collection.insertOne(document);

      if (result.isSuccess) {
        document['_id'] = result.id;
        LogHelper.success(
          'MongoDB',
          'Document berhasil disimpan dengan ID: ${result.id}',
        );
        return document;
      } else {
        throw Exception('Insert gagal: ${result.errmsg}');
      }
    } catch (e, stackTrace) {
      LogHelper.error('MongoDB', 'Gagal insert document', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    return getLogs();
  }

  // Alias untuk Task 3 requirement
  Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      LogHelper.info('MongoDB', 'Mengambil semua documents...');
      dev.log(
        '[MongoService.getLogs] Sebelum collection.find().toList()',
        name: 'MongoDB',
        level: 300,
      );

      final documents = await collection.find().toList();

      dev.log(
        'JUMLAH DATA MENTAH DARI MONGODB: ${documents.length}',
        name: 'DEBUG_DB',
      );
      dev.log(
        'ISI DATA PERTAMA: ${documents.isNotEmpty ? documents.first.toString() : 'KOSONG'}',
        name: 'DEBUG_DB',
      );

      dev.log(
        '[MongoService.getLogs] Setelah collection.find().toList(), total=${documents.length}',
        name: 'MongoDB',
        level: 300,
      );
      LogHelper.success(
        'MongoDB',
        'Berhasil mengambil ${documents.length} documents',
      );
      return documents;
    } catch (e, stackTrace) {
      dev.log(
        '[MongoService.getLogs] Exception saat mengambil documents: $e',
        name: 'MongoDB',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      LogHelper.error('MongoDB', 'Gagal mengambil documents', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateDocument(ObjectId id, Map<String, dynamic> updates) async {
    try {
      LogHelper.info('MongoDB', 'Update document ID: $id');

      final result = await collection.updateOne(
        where.id(id),
        modify
            .set('title', updates['title'])
            .set('description', updates['description'])
            .set('timestamp', updates['timestamp'])
            .set('category', updates['category']),
      );

      if (result.isSuccess) {
        LogHelper.success('MongoDB', 'Document berhasil diupdate');
      } else {
        throw Exception('Update gagal');
      }
    } catch (e, stackTrace) {
      LogHelper.error('MongoDB', 'Gagal update document', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteDocument(ObjectId id) async {
    try {
      LogHelper.info('MongoDB', 'Delete document ID: $id');

      final result = await collection.deleteOne(where.id(id));

      if (result.isSuccess) {
        LogHelper.success('MongoDB', 'Document berhasil dihapus');
      } else {
        throw Exception('Delete gagal');
      }
    } catch (e, stackTrace) {
      LogHelper.error('MongoDB', 'Gagal delete document', e, stackTrace);
      rethrow;
    }
  }
}
