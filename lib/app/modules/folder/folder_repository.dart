import 'package:http/http.dart' as http;
import 'package:projectv2/app/modules/folder/folder_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class FolderRepository {
  final String baseUrl = 'http://10.0.2.2:5101/api/MapPoints';

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
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FolderItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load map points (${response.statusCode})');
    }
  }
}
