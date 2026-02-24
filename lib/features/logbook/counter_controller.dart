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
  void _addLog(String action, String type) {
    // Mengambil waktu saat ini
    String time = DateTime.now().toString().split('.')[0].split(' ')[1];
    
    // Menambahkan catatan ke urutan paling atas
    _history.insert(0, "$type|$action pada jam $time");

    // Membatasi agar riwayat hanya menampilkan 5 aktivitas terakhir 
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // Fungsi-fungsi utama untuk Step dan Log
  void increment() {
    _counter += _step;
    _addLog("User menambah nilai sebesar $_step", "POS");
  }

  void decrement() {
    // Membatasi agar nilai tidak menjadi negatif
    if (_counter >= _step) {
      _counter -= _step;
      _addLog("User mengurangi nilai sebesar $_step", "NEG"); 
    } else {
      _counter = 0;
      _addLog("Reset ke 0", "NEG");
    }
  }

  void reset() {
    _counter = 0;
    _addLog("User melakukan reset nilai", "RESET");
  }
}