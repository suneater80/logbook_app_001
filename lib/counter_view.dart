import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

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
                const SizedBox(width: 10), // Beri jarak antar tombol
                ElevatedButton(
                  onPressed: () => setState(() => _controller.reset()),
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
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(log, style: const TextStyle(fontSize: 12)),
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
