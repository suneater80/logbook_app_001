class LoginController {
  // Database dengan multiple user
  final Map<String, String> _validUsers = {
    "admin": "123",
    "user1": "pass1",
    "hakim": "hakim123",
  };
  // Fungsi pengecekan dengan Map
  bool login(String username, String password) {
    if (_validUsers.containsKey(username) &&
        _validUsers[username] == password) {
      return true;
    }
    return false;
  }
}
