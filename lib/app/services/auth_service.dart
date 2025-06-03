import 'dart:async';

class AuthService {
  static Future<bool> login(String username, String password) async {
    // Simulasi delay seperti panggil API
    await Future.delayed(Duration(seconds: 2));
    
    // Validasi dummy (opsional)
    if (username == "admin123" && password == "12345678") {
      return true;
    }

    return false; // Gagal login
  }

  static Future<bool> register(String username, String email, String password) async {
    // Simulasi delay
    await Future.delayed(Duration(seconds: 2));
    
    // Selalu berhasil daftar (simulasi)
    return true;
  }
}