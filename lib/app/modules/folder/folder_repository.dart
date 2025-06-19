import 'package:http/http.dart' as http;
import 'package:projectv2/app/modules/folder/folder_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class FolderRepository {
  final String baseUrl = 'http://103.183.75.71:5101/api/MapPoints';

Future<List<FolderItemModel>> fetchMapPoints() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken'); 
  print('Token: $token');

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
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}'); 

  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded = json.decode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];
    return data.map((json) => FolderItemModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load map points (${response.statusCode})');
  }
}

  Future<void> deleteMapPoint(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'), // DELETE ke endpoint MapPoints/{id}
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Delete status: ${response.statusCode}');
    print('Delete body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data (${response.statusCode})');
    }
  }

  Future<void> updateMapPoint(FolderItemModel point) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

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

    if (response.statusCode != 200) {
      throw Exception('Gagal update data (${response.statusCode})');
    }
  }


}
