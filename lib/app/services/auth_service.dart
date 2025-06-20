import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? role;

  UserModel({this.id, this.fullName, this.email, this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString(),
      fullName:
          json['fullName'] ??
          json['FullName'] ??
          json['fullname'] ??
          json['name'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class AuthService {
  static const String baseUrl = 'http://103.183.75.71:5101';

  /// ✅ Simpan token dan data user ke SharedPreferences
  static Future<void> saveTokensAndUser(
    String accessToken,
    String refreshToken,
    String email,
    String fullname,
    String role, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userEmail', email);
    await prefs.setString('userFullname', fullname);
    await prefs.setString('userRole', role);
    if (userId != null) {
      await prefs.setString('userId', userId);
      print("✅ userId saved to prefs: $userId");
    } else {
      print("⚠️ userId not found in token");
    }
  }

  /// ✅ Ambil info user dari SharedPreferences
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final fullname = prefs.getString('userFullname');
    final role = prefs.getString('userRole');
    final id = prefs.getString('userId');
    if (email != null && fullname != null) {
      return UserModel(id: id, fullName: fullname, email: email, role: role);
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

  /// ✅ Login dan decode userId dari token (diperbaiki)
  static Future<bool> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/apiauth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['accessToken'];

      // ✅ Decode token dan ambil userId dari JWT claim yg sesuai
      final decoded = JwtDecoder.decode(accessToken);
      final userId =
          decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              ?.toString() ??
          decoded['sub']?.toString() ??
          decoded['id']?.toString() ??
          decoded['userId']?.toString();

      print("✅ LOGIN: userId dari token: $userId");

      await saveTokensAndUser(
        accessToken,
        data['refreshToken'],
        data['email'] ?? email,
        data['fullName'] ??
            data['FullName'] ??
            data['fullname'] ??
            data['name'] ??
            '',
        data['role'] ?? '',
        userId: userId,
      );
      return true;
    } else {
      print("❌ LOGIN Gagal: ${response.statusCode}");
      return false;
    }
  }

  /// ✅ Register dan simpan userId dari JWT juga
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
      final accessToken = data['accessToken'];

      final decoded = JwtDecoder.decode(accessToken);
      final userId =
          decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              ?.toString() ??
          decoded['sub']?.toString() ??
          decoded['id']?.toString() ??
          decoded['userId']?.toString();

      print("✅ REGISTER: userId dari token: $userId");

      await saveTokensAndUser(
        accessToken,
        data['refreshToken'],
        data['email'] ?? email,
        data['fullName'] ??
            data['FullName'] ??
            data['fullname'] ??
            data['name'] ??
            fullname,
        data['role'] ?? '',
        userId: userId,
      );
      return true;
    } else {
      print("❌ REGISTER Gagal: ${response.statusCode}");
      return false;
    }
  }

  /// ✅ Hapus semua token saat logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("👋 Logout berhasil, semua token dibersihkan");
  }
}
