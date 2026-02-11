class CounterController {
  int _counter = 0; // Variabel private untuk menyimpan angka utama
  int _step = 1;    // Variabel untuk menyimpan nilai langkah
  
  // List private untuk menampung history
  List<String> _history = [];

  // Getter untuk memberikan akses baca ke View
  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  // Fungsi untuk mengubah nilai step berdasarkan input User
  void setStep(int newValue) {
    _step = newValue;
  }

  // Fungsi untuk menambah log history dan membatasi jumlahnya
  void _addLog(String action) {
    // Mengambil waktu saat ini
    String time = DateTime.now().toString().split('.')[0];
    
    // Menambahkan catatan ke urutan paling atas
    _history.insert(0, "$action (Step: $_step) pada $time");

    // Membatasi agar riwayat hanya menampilkan 5 aktivitas terakhir 
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // Fungsi-fungsi utama untuk Step dan Log
  void increment() {
    _counter += _step;
    _addLog("Tambah +$_step");
  }

  void decrement() {
    // Membatasi agar nilai tidak menjadi negatif
    if (_counter >= _step) {
      _counter -= _step;
      _addLog("Kurang -$_step");
    } else {
      _counter = 0;
      _addLog("Reset ke 0 (karena kurang dari step)");
    }
  }

  void reset() {
    _counter = 0;
    _addLog("Reset Angka");
  }
}