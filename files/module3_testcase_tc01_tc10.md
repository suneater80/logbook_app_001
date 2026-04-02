# Modul 3 - Test Case OnboardingView (TC01-TC10)

Dokumen ini disusun dalam bentuk tabel supaya mudah dipindahkan ke Excel. Penulisan langkah, data test, dan ekspektasi dibuat seragam seperti template dosen.

## TestCase (Sheet TestCase)

| Test Case ID | Modul Uji | Test Type | Nama Test Case | Prekondisi | Langkah Pengujian | Data Test | Ekspektasi |
|---|---|---|---|---|---|---|---|
| TC01 | OnboardingData | Positif | onboarding data should store first slide information correctly | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi data onboarding<br>2. Buat objek OnboardingData sesuai data test<br><br>exercise (act, operate)<br>3. Get nilai field image, title, dan description sebagai nilai aktual<br><br>verify (assert, check)<br>4. Bandingkan nilai aktual dan ekspektasi | image = assets/images/onboarding1.png<br>title = Selamat Datang<br>description = Aplikasi LogBook membantu Anda mencatat setiap aktivitas dengan mudah dan rapi. | data onboarding pertama sesuai test data |
| TC02 | OnboardingView | Positif | onboarding first page should show welcome title | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Render halaman onboarding pertama sebagai nilai aktual<br><br>verify (assert, check)<br>4. Bandingkan nilai aktual dan ekspektasi | halaman awal onboarding | teks Selamat Datang tampil |
| TC03 | OnboardingView | Positif | onboarding first page should show Skip and Next buttons | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Render halaman onboarding pertama sebagai nilai aktual<br><br>verify (assert, check)<br>4. Bandingkan nilai aktual dan ekspektasi | halaman awal onboarding | tombol Skip dan Next tampil |
| TC04 | OnboardingView | Positif | pressing Next should move to second page | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Tekan tombol Next satu kali sebagai aksi utama<br>4. Get halaman aktif setelah perpindahan sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | tekan Next 1 kali | halaman kedua tampil dengan judul Kelola Counter |
| TC05 | OnboardingView | Positif | pressing Next again should move to third page | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Tekan tombol Next dua kali sebagai aksi utama<br>4. Get halaman aktif setelah perpindahan sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | tekan Next 2 kali | halaman ketiga tampil dengan judul Pantau Riwayat |
| TC06 | OnboardingView | Positif | last page button should change to Get Started | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Buka halaman terakhir onboarding sebagai nilai aktual<br><br>verify (assert, check)<br>4. Bandingkan nilai aktual dan ekspektasi | halaman ketiga onboarding | tombol Get Started tampil |
| TC07 | OnboardingView | Positif | pressing Skip should jump to last page | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Tekan tombol Skip sebagai aksi utama<br>4. Get halaman aktif setelah perpindahan sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | tekan Skip | halaman ketiga tampil dengan judul Pantau Riwayat |
| TC08 | OnboardingView | Positif | pressing Get Started should navigate to LoginView | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Tekan tombol Get Started sebagai aksi utama<br>4. Get halaman tujuan navigasi sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | tekan Get Started | halaman Login Gatekeeper tampil |
| TC09 | OnboardingView | Positif | swiping left should move to the second onboarding page | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Geser PageView ke halaman berikutnya sebagai aksi utama<br>4. Get halaman aktif setelah geser sebagai nilai aktual<br><br>verify (assert, check)<br>5. Bandingkan nilai aktual dan ekspektasi | swipe ke kiri satu kali | halaman kedua tampil dengan judul Kelola Counter |
| TC10 | OnboardingView | Positif | onboarding screen should show page indicator | Program siap dijalankan | setup (arrange, build)<br>1. Inisialisasi widget test<br>2. Buat objek OnboardingView di dalam MaterialApp<br><br>exercise (act, operate)<br>3. Render halaman onboarding sebagai nilai aktual<br><br>verify (assert, check)<br>4. Bandingkan nilai aktual dan ekspektasi | tampilan onboarding | page indicator tampil |

## TestCaseResult (Sheet TestCaseResult)

| Test Case ID | Ekspektasi | Actual | Hasil |
|---|---|---|---|
| TC01 | data onboarding pertama sesuai test data | data onboarding pertama sesuai test data | Pass |
| TC02 | teks Selamat Datang tampil | teks Selamat Datang tampil | Pass |
| TC03 | tombol Skip dan Next tampil | tombol Skip dan Next tampil | Pass |
| TC04 | halaman kedua tampil dengan judul Kelola Counter | halaman kedua tampil dengan judul Kelola Counter | Pass |
| TC05 | halaman ketiga tampil dengan judul Pantau Riwayat | halaman ketiga tampil dengan judul Pantau Riwayat | Pass |
| TC06 | tombol Get Started tampil | tombol Get Started tampil | Pass |
| TC07 | halaman ketiga tampil dengan judul Pantau Riwayat | halaman ketiga tampil dengan judul Pantau Riwayat | Pass |
| TC08 | halaman Login Gatekeeper tampil | halaman Login Gatekeeper tampil | Pass |
| TC09 | halaman kedua tampil dengan judul Kelola Counter | halaman kedua tampil dengan judul Kelola Counter | Pass |
| TC10 | page indicator tampil | page indicator tampil | Pass |

## Summary (Sheet Summary)

| Modul Uji | Jumlah Test Case | # TC Pass | # TC Fail |
|---|---:|---:|---:|
| OnboardingData / OnboardingView | 10 | 10 | 0 |

Total Test Case: 10

Total Test Pass: 10

Total Test Fail: 0

## Evidence (Sheet Evidence)

| ID | Modul Uji | Test Case ID | Deskripsi Bug | Langkah Reproduksi | Ekspektasi | Realita |
|---|---|---|---|---|---|---|
| EV-01 | OnboardingData / OnboardingView | TC01-TC10 | Tidak ditemukan bug pada pengujian modul 3 | Jalankan flutter test pada script modul 3 | Semua test case pass | Semua test case pass |
