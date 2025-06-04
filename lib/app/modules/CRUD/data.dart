import 'dart:io';
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
    return prefs.getString(
      'jwtToken',
    ); // Ganti dengan key penyimpanan token milikmu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Lokasi')),
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
                final token = await AuthService.getAccessToken();
                print("JWT Token: $token");

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token JWT tidak ditemukan')),
                  );
                  return;
                }

                final name = nameController.text;
                final description = descriptionController.text;
                final lat = widget.position.latitude.toString();
                final lng = widget.position.longitude.toString();

                var uri = Uri.parse(
                  'http://192.168.110.189:5101/api/mappoints', // Ganti sesuai IP/domain backend kamu
                );

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

                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data lokasi disimpan ke server'),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  final error = await response.stream.bytesToString();
                  print("Gagal: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gagal menyimpan data (${response.statusCode})',
                      ),
                    ),
                  );
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
