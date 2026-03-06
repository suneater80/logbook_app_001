import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/helpers/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    // Memuat env sekali di awal untuk semua test
    await dotenv.load(fileName: ".env");
  });

  test(
    'Memastikan koneksi ke MongoDB Atlas berhasil via MongoService',
    () async {
      final mongoService = MongoService.instance;

      // Memanfaatkan LogHelper baru yang sudah pakai dev.log dan print berwarna
      LogHelper.info(sourceFile, "--- START CONNECTION TEST ---");

      try {
        // Mengetes koneksi
        await mongoService.init();

        // Ekspektasi: URI tidak null dan koneksi berhasil
        expect(dotenv.env['MONGO_URL'], isNotNull);
        expect(mongoService.isConnected, isTrue);

        LogHelper.success(sourceFile, "SUCCESS: Koneksi Atlas Terverifikasi");
      } catch (e) {
        LogHelper.error(
          sourceFile,
          "ERROR: Kegagalan koneksi",
          e,
          StackTrace.current,
        );
        fail("Koneksi gagal: $e");
      } finally {
        // Selalu tutup koneksi agar tidak menggantung di dashboard Atlas
        await mongoService.close();
        LogHelper.info(sourceFile, "--- END TEST ---");
      }
    },
  );
}
