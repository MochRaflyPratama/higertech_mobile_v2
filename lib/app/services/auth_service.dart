import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.110.189:5101'; // Ganti sesuai IP kamu

  /// Login ke API dan simpan JWT + RefreshToken + UserId ke SharedPreferences
  static Future<bool> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/apiauth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);


      return true;
    } else {
      return false;
    }
  }

  /// Register user baru ke API
  /// Return true jika sukses, false jika gagal
  static Future<bool> register(
    String email,
    String password,
    String fullname,
  ) async {
    final uri = Uri.parse('$baseUrl/api/apiauth/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullname': fullname,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Bisa juga auto-login di sini jika API mengembalikan token
      return true;
    } else {
      // Optional: print error message
      // print('Register failed: ${response.body}');
      return false;
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
