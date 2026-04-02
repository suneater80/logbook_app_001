# Modul 2 - Test Case LoginController (TC01-TC10)

Dokumen ini disusun dalam bentuk tabel agar mudah dipindahkan ke Excel. Penulisan langkah, data test, dan ekspektasi dibuat seragam seperti template dosen.

## TestCase (Sheet TestCase)

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | login(String username, String password) | Positif | login should return true for admin valid credential | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = admin<br>password = 123 | nilai login berhasil, yaitu true |
| TC02 | login(String username, String password) | Positif | login should return true for user1 valid credential | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = user1<br>password = pass1 | nilai login berhasil, yaitu true |
| TC03 | login(String username, String password) | Positif | login should return true for hakim valid credential | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = hakim<br>password = hakim123 | nilai login berhasil, yaitu true |
| TC04 | login(String username, String password) | Negatif | login should return false for wrong password | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = admin<br>password = 321 | nilai login gagal, yaitu false |
| TC05 | login(String username, String password) | Negatif | login should return false for unknown username | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = guest<br>password = 123 | nilai login gagal, yaitu false |
| TC06 | login(String username, String password) | Negatif | login should return false for invalid username and password | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = x<br>password = y | nilai login gagal, yaitu false |
| TC07 | login(String username, String password) | Negatif | login should return false when username is empty | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = (kosong)<br>password = 123 | nilai login gagal, yaitu false |
| TC08 | login(String username, String password) | Negatif | login should return false when password is empty | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = admin<br>password = (kosong) | nilai login gagal, yaitu false |
| TC09 | login(String username, String password) | Negatif | login should return false for uppercase username | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = ADMIN<br>password = 123 | nilai login gagal, yaitu false |
| TC10 | login(String username, String password) | Negatif | login should return false for username with trailing space | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi objek LoginController<br>2. Siapkan username dan password sesuai data test<br><br>exercise (act, operate)<br>3. Panggil fungsi login dengan parameter sesuai test data<br>4. Get nilai hasil eksekusi program sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | username = admin (dengan spasi di akhir)<br>password = 123 | nilai login gagal, yaitu false |

## TestCaseResult (Sheet TestCaseResult)

| Test Case ID | Ekspektasi | Actual | Hasil |
|---|---|---|---|
| TC01 | nilai login berhasil, yaitu true | nilai login berhasil, yaitu true | Pass |
| TC02 | nilai login berhasil, yaitu true | nilai login berhasil, yaitu true | Pass |
| TC03 | nilai login berhasil, yaitu true | nilai login berhasil, yaitu true | Pass |
| TC04 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |
| TC05 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |
| TC06 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |
| TC07 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |
| TC08 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |
| TC09 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |
| TC10 | nilai login gagal, yaitu false | nilai login gagal, yaitu false | Pass |

## Summary (Sheet Summary)

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---:|---:|---:|
| login(String username, String password) | 10 | 10 | 0 |

Total Test Case: 10

Total Test Pass: 10

Total Test Fail: 0

## Evidence (Sheet Evidence)

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita |
|---|---|---|---|---|---|---|
| EV-01 | login(String username, String password) | TC01-TC10 | Tidak ditemukan bug pada pengujian modul 2 | Jalankan flutter test pada script modul 2 | Semua test case pass | Semua test case pass |
