import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectv2/app/modules/folder/folder_model.dart';
import 'package:projectv2/app/services/auth_service.dart';

class FolderRepository {
  final String baseUrl = 'http://103.183.75.71:5101/api/MapPoints';

  /// Ambil semua map points dari API
  Future<List<FolderItemModel>> fetchMapPoints() async {
    final token = await AuthService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📥 GET Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      return data.map((json) => FolderItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data (${response.statusCode})');
    }
  }

  /// Hapus map point berdasarkan ID
  Future<void> deleteMapPoint(int id) async {
    final token = await AuthService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🗑️ DELETE Status: ${response.statusCode}');
    print('🗑️ DELETE Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus data (${response.statusCode})');
    }
  }

  /// Update map point berdasarkan model
  Future<void> updateMapPoint(FolderItemModel point) async {
    final token = await AuthService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/${point.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id': point.id,
        'title': point.title,
        'description': point.description,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'imageUrl': point.imageUrl,
      }),
    );

    print('✏️ UPDATE Status: ${response.statusCode}');
    print('✏️ UPDATE Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal update data (${response.statusCode})');
    }
  }
}
