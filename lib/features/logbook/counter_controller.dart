import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0; // Variabel private untuk menyimpan nilai counter
  int _step = 1; // Variabel private untuk menyimpan nilai step
  final List<String> _history = []; // List private untuk menampung history

  // Getter untuk memberikan akses baca ke View
  int get value => _counter;
  int get step => _step;
  List<String> get history =>
      List.unmodifiable(_history); // Memberikan akses read-only ke history

  static String _counterKey(String username) =>
      "counter_$username"; // Key untuk SharedPreferences berdasarkan username

  static String _historyKey(String username) => 'history_$username';

  Future<void> loadCounter(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt(_counterKey(username)) ?? 0;

    // Memuat history dari SharedPreferences
    final savedHistory = prefs.getStringList(_historyKey(username)) ?? [];
    _history.clear();
    _history.addAll(savedHistory);
  }

  Future<void> _saveCounter(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey(username), _counter);
  }

  Future<void> _saveHistory(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey(username), _history);
  }

  // Fungsi untuk mengubah nilai step berdasarkan input User
  void setStep(int newValue) {
    _step = newValue <= 0
        ? 1
        : newValue; // Pastikan step tidak negatif atau nol
  }

  String _timeNow() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // Fungsi untuk menambah log history dan membatasi jumlahnya
  void _addLog({
    required String username,
    required String actionText,
    required String type,
  }) {
    final log = "$type|User $username $actionText pada jam ${_timeNow()}";
    _history.insert(0, log);

    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // Fungsi-fungsi utama untuk Step dan Log
  Future<void> increment(String username) async {
    _counter += _step;
    _addLog(username: username, actionText: "menambah +$_step", type: "POS");
    await _saveCounter(username);
    await _saveHistory(username);
  }

  Future<void> decrement(String username) async {
    final dec = _counter >= _step ? _step : _counter;
    _counter -= dec;
    _addLog(username: username, actionText: "mengurangi -$dec", type: "NEG");
    await _saveCounter(username);
    await _saveHistory(username);
  }

  Future<void> reset(String username) async {
    _counter = 0;
    _addLog(
      username: username,
      actionText: "melakukan reset ke 0",
      type: "RESET",
    );
    await _saveCounter(username);
    await _saveHistory(username);
  }
}
