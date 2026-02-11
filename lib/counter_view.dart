import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

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
            onPressed: () {
              setState(() => _controller.reset());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
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
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),


      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: TextField(
                keyboardType: TextInputType.number, // menambahkan keyboard numerik
                decoration: const InputDecoration(
                  labelText: "Nilai Step",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // penanganan kesalahan input
                  int inputStep = int.tryParse(value) ?? 1;
                  _controller.setStep(inputStep); // Memanggil fungsi di Controller
                },
              ),
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton( // Menggunakan ElevatedButton agar lebih pas di dalam Column
                  onPressed: () => setState(() => _controller.increment()),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 10),  // Beri jarak antar tombol
                ElevatedButton(
                  onPressed: _showResetDialog, // Menggunakan Dialog
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _controller.decrement()),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),

            const Divider(height: 40), // Garis pemisah
            const Text("Riwayat Aktivitas :", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Menampilkan riwayat 
            Column(
              children: _controller.history.map((log) {

                // Memisahkan String berdasarkan karakter '|'
                final parts = log.split('|');
                if (parts.length < 2) return const SizedBox(); // Jika format tidak sesuai, lewati log ini
                final String type = parts[0];
                final String message = parts[1];

                // Menentukan warna
                Color displayColor = Colors.grey;
                if (type == "POS") displayColor = Colors.green;
                if (type == "NEG") displayColor = Colors.red;

                return Card(
                  child: ListTile(
                    // PASANG WARNA DI SINI
                    leading: Icon(Icons.history, color: displayColor),
                    title: Text(
                      message,
                      style: TextStyle(
                        fontSize: 12, 
                        color: displayColor, // PASANG WARNA DI SINI
                        fontWeight: FontWeight.w600
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
