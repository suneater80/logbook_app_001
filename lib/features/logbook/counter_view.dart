import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/logbook/log_view.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class CounterView extends StatefulWidget {
  // Tambahkan variabel final untuk menampung nama
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  String _resolveRole(String username) {
    if (username.trim().toLowerCase() == 'admin') {
      return 'Ketua';
    }
    return 'Anggota';
  }

  String _resolveTeamId(String username) {
    final normalized = username.trim().toLowerCase();
    if (normalized == 'admin' || normalized == 'hakim') {
      return 'team_alpha';
    }
    return 'team_beta';
  }

  // Fungsi greeting berdasarkan waktu
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _getSubtitle() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return 'awali hari dengan bismillah';
    if (hour >= 11 && hour < 15) return 'bobo siang yuk';
    if (hour >= 15 && hour < 18) return 'nyari takjil gass';
    return 'Selamat beristirahat bro/sis!';
  }

  late final CounterController _controller;
  bool _isLoading = true; // Menambahkan state untuk loading

  @override
  void initState() {
    super.initState();
    _controller = CounterController(); // Inisialisasi Controller
    _initCounter();
  }

  Future<void> _initCounter() async {
    await _controller.loadCounter(
      widget.username,
    ); // Memuat nilai counter berdasarkan username
    if (!mounted) return;
    setState(() {
      _isLoading = false; // Setelah data dimuat, set loading ke false
    });
  }

  Future<void> _onIncrement() async {
    await _controller.increment(widget.username);
    if (!mounted) return;
    setState(
      () {},
    ); // Memanggil setState untuk memperbarui UI setelah increment
  }

  Future<void> _onDecrement() async {
    await _controller.decrement(widget.username);
    if (!mounted) return;
    setState(
      () {},
    ); // Memanggil setState untuk memperbarui UI setelah decrement
  }

  Future<void> _onReset() async {
    await _controller.reset(widget.username);
    if (!mounted) return;
    setState(() {}); // Memanggil setState untuk memperbarui UI setelah reset
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Reset"),
        content: const Text("Apakah Anda yakin ingin meriset semua hitungan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _onReset();
              if (!mounted) return;
              Navigator.of(this.context).pop();
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text("Nilai berhasil direset")),
              );
            },
            child: const Text("Ya, Reset"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Buka Log CRUD',
            onPressed: () {
              final currentRole = _resolveRole(widget.username);
              final currentTeamId = _resolveTeamId(widget.username);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogView(
                    currentUserUid: widget.username,
                    currentUserRole: currentRole,
                    currentUserTeamId: currentTeamId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            // Logout
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1. Munculkan Dialog Konfirmasi
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text(
                      "Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang.",
                    ),
                    actions: [
                      // Tombol Batal
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context), // Menutup dialog saja
                        child: const Text("Batal"),
                      ),
                      // Tombol Ya, Logout
                      TextButton(
                        onPressed: () async {
                          // 1. Tangkap navigator sebelum kena efek async
                          final navigator = Navigator.of(context);

                          // 2. Tutup dialog pop-up konfirmasi
                          navigator.pop();

                          // 3. Bersihkan sisa data di laci memori lokal
                          await Hive.box<LogModel>('offline_logs').clear();

                          // 4. Pergi ke halaman Login
                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginView(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Ya, Keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout != true) return;
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, ${widget.username}! 🙂‍↕️',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(),
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: TextField(
                keyboardType:
                    TextInputType.number, // menambahkan keyboard numerik
                decoration: const InputDecoration(
                  labelText: "Nilai Step",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // penanganan kesalahan input
                  int inputStep = int.tryParse(value) ?? 1;
                  _controller.setStep(
                    inputStep,
                  ); // Memanggil fungsi di Controller
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  // Menggunakan ElevatedButton agar lebih pas di dalam Column
                  onPressed: _onIncrement, // Memanggil fungsi increment
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 10), // Beri jarak antar tombol

                ElevatedButton(
                  onPressed: _showResetDialog, // Menggunakan Dialog
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: _onDecrement, // Memanggil fungsi decrement
                  child: const Icon(Icons.remove),
                ),
              ],
            ),

            const Divider(height: 40), // Garis pemisah
            const Text(
              "Riwayat Aktivitas :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Menampilkan riwayat
            Column(
              children: _controller.history.map((log) {
                // Memisahkan String berdasarkan karakter '|'
                final parts = log.split('|');
                if (parts.length < 2) {
                  return const SizedBox(); // Jika format tidak sesuai, lewati log ini
                }
                final String type = parts[0];
                final String message = parts[1];

                // Menentukan warna
                Color displayColor = Colors.grey;
                if (type == "POS") displayColor = Colors.green;
                if (type == "NEG") displayColor = Colors.red;

                return Card(
                  child: ListTile(
                    // Menampilkan ikon yang berbeda berdasarkan jenis log
                    leading: Icon(Icons.history, color: displayColor),
                    title: Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: displayColor, // Warna teks mengikuti jenis log
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
