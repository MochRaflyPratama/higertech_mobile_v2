import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String? fullName;
  final String? email;
  final String? role;
  UserModel({this.fullName, this.email, this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? json['FullName'] ?? json['fullname'] ?? json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5101'; // Ganti sesuai IP kamu

  /// Simpan token dan data user ke SharedPreferences
  static Future<void> saveTokensAndUser(String accessToken, String refreshToken, String email, String fullname, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userEmail', email);
    await prefs.setString('userFullname', fullname);
    await prefs.setString('userRole', role);
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final fullname = prefs.getString('userFullname');
    final role = prefs.getString('userRole');
    if (email != null && fullname != null) {
      return UserModel(fullName: fullname, email: email, role: role);
    }
    return null;
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  static Future<bool> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/apiauth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokensAndUser(
        data['accessToken'],
        data['refreshToken'],
        data['email'] ?? email,
        data['fullName'] ?? data['FullName'] ?? data['fullname'] ?? data['name'] ?? '',
        data['role'] ?? '',
      );
      return true;
    } else {
      return false;
    }
  }

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
      final data = jsonDecode(response.body);
      await saveTokensAndUser(
        data['accessToken'],
        data['refreshToken'],
        data['email'] ?? email,
        data['fullName'] ?? data['FullName'] ?? data['fullname'] ?? data['name'] ?? fullname,
        data['role'] ?? '',
      );
      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
