// login_view.dart
import 'package:flutter/material.dart';
// Import Controller milik sendiri (masih satu folder)
import 'package:logbook_app_001/features/auth/login_controller.dart';
// Import View dari fitur lain (Logbook) untuk navigasi
import 'package:logbook_app_001/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Security
  int _failedAttempts = 0;
  bool _isButtonDisabled = false;
  int _remainingTime = 0;

  // Variabel untuk show/hide password
  bool _isPasswordVisible = false;

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    // Validasi Field Kosong
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cek Login
    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      // Reset Failed Attempts
      _failedAttempts = 0;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Di sini kita kirimkan variabel 'user' ke parameter 'username' di CounterView
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      setState(() {
        _failedAttempts++;
      });

      // Cek jika sudah 3 kali gagal
      if (_failedAttempts >= 3) {
        _disableButtonFor10Seconds();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal! Percobaan ke-$_failedAttempts dari 3"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _disableButtonFor10Seconds() {
    setState(() {
      _isButtonDisabled = true;
      _remainingTime = 10; // 10 detik
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Terlalu banyak percobaan! Tunggu 10 detik."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );

    // Timer untuk menghitung mundur
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _remainingTime--;
      });

      // jika waktu habis, aktifkan kembali tombol
      if (_remainingTime <= 0) {
        setState(() {
          _isButtonDisabled = false;
          _failedAttempts = 0; // reset percobaan
        });
        return false; // hentikan loop
      }

      return true; // lanjutkan loop
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),

            TextField(
              controller: _passController,
              obscureText: !_isPasswordVisible, // Menyembunyikan teks password
              decoration: InputDecoration(
                labelText: "Password",
                //membuat ikon mata
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible =
                          !_isPasswordVisible; // Toggle visibility
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _handleLogin,
              child: Text(
                _isButtonDisabled ? "Tunggu $_remainingTime detik" : "Masuk",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
