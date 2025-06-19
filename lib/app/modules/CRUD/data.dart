import 'dart:io';
import 'dart:convert';
import 'package:projectv2/app/services/auth_service.dart'; // sesuaikan path
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:projectv2/app/modules/camera/Camerascreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationFormPage extends StatefulWidget {
  final LatLng position;

  const LocationFormPage({super.key, required this.position});

  @override
  State<LocationFormPage> createState() => _LocationFormPageState();
}

class _LocationFormPageState extends State<LocationFormPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken'); // Key disamakan dengan AuthService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Lokasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
      ),
      backgroundColor: const Color(0xFF2D2E49),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Koordinat: ${widget.position.latitude}, ${widget.position.longitude}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final File? image = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ImagePickerScreen()),
                    );

                    if (image != null) {
                      setState(() {
                        selectedImage = image;
                      });
                    }
                    final token = await _getJwtToken();
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.file(selectedImage!, height: 100),
              ),
            ElevatedButton(
              onPressed: () async {
                Future<bool> sendLocationData(String token) async {
                  final name = nameController.text;
                  final description = descriptionController.text;
                  final lat = widget.position.latitude.toString();
                  final lng = widget.position.longitude.toString();

                  var uri = Uri.parse('http://103.183.75.71:5101/api/mappoints');

                  var request =
                      http.MultipartRequest('POST', uri)
                        ..fields['Title'] = name
                        ..fields['Description'] = description
                        ..fields['Latitude'] = lat
                        ..fields['Longitude'] = lng
                        ..headers['Authorization'] = 'Bearer $token';

                  if (selectedImage != null) {
                    var imageFile = await http.MultipartFile.fromPath(
                      'Image',
                      selectedImage!.path,
                      filename: basename(selectedImage!.path),
                    );
                    request.files.add(imageFile);
                  }

                  var response = await request.send();
                  print('Status code: \\${response.statusCode}');
                  final responseBody = await response.stream.bytesToString();
                  print('Response body: \\${responseBody}');
                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data lokasi disimpan ke server'),
                      ),
                    );
                    Navigator.pop(context);
                    return true;
                  } else if (response.statusCode == 401) {
                    return false; // Token expired/unauthorized
                  } else {
                    print("Gagal: $responseBody");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gagal menyimpan data (${response.statusCode})',
                        ),
                      ),
                    );
                    return true; // Sudah ditangani, tidak perlu retry
                  }
                }

                Future<bool> refreshAccessToken() async {
                  final refreshToken = await AuthService.getRefreshToken();
                  if (refreshToken == null) return false;
                  final uri = Uri.parse(
                    'http://103.183.75.71:5101/api/apiauth/refresh',
                  );
                  final response = await http.post(
                    uri,
                    headers: {'Content-Type': 'application/json'},
                    body: '"$refreshToken"', // Kirim string token dengan kutip
                  );
                  if (response.statusCode == 200) {
                    final decoded = jsonDecode(response.body);
                    await AuthService.saveTokensAndUser(
                      decoded['accessToken'],
                      decoded['refreshToken'],
                      '', // email tidak tersedia saat refresh
                      '', // fullname tidak tersedia saat refresh
                      '', // role tidak tersedia saat refresh
                    );
                    return true;
                  }
                  return false;
                }

                var token = await AuthService.getAccessToken();
                print("JWT Token: $token");
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token JWT tidak ditemukan')),
                  );
                  return;
                }

                bool success = await sendLocationData(token);
                if (!success) {
                  // Coba refresh token
                  bool refreshed = await refreshAccessToken();
                  if (refreshed) {
                    final newToken = await AuthService.getAccessToken();
                    await sendLocationData(newToken!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sesi login habis, silakan login ulang.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
