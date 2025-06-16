import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:projectv2/app/modules/folder/folder_model.dart';
import 'package:projectv2/app/modules/folder/folder_controller.dart';

class EditFolderView extends StatefulWidget {
  final FolderItemModel point;

  const EditFolderView({super.key, required this.point});

  @override
  State<EditFolderView> createState() => _EditFolderViewState();
}

class _EditFolderViewState extends State<EditFolderView> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController latController;
  late TextEditingController longController;

  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.point.title ?? '');
    descriptionController = TextEditingController(text: widget.point.description ?? '');
    latController = TextEditingController(text: widget.point.latitude.toString());
    longController = TextEditingController(text: widget.point.longitude.toString());
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    latController.dispose();
    longController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updatePoint() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Token tidak ditemukan.');
      return;
    }

    // Validasi sederhana
    if (titleController.text.isEmpty || latController.text.isEmpty || longController.text.isEmpty) {
      setState(() => isLoading = false);
      Get.snackbar('Validasi', 'Semua data wajib diisi.');
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:5101/api/MapPoints/${widget.point.id}');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['Title'] = titleController.text
      ..fields['Description'] = descriptionController.text
      ..fields['Latitude'] = latController.text
      ..fields['Longitude'] = longController.text
      ..headers['Authorization'] = 'Bearer $token';

    if (selectedImage != null) {
      final image = await http.MultipartFile.fromPath(
        'Image',
        selectedImage!.path,
        filename: basename(selectedImage!.path),
      );
      request.files.add(image);
    }

    final response = await request.send();

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 204) {
      Get.snackbar('Sukses', 'Data berhasil diperbarui', snackPosition: SnackPosition.BOTTOM);
      Get.find<FolderController>().fetchPoints();// refresh data
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.back(); // Kembali ke halaman sebelumnya
      });
    } else {
      final body = await response.stream.bytesToString();
      print("Error response: $body");
      Get.snackbar('Error', 'Gagal memperbarui data (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Map Point'),
        backgroundColor: const Color(0xFF2D2E49),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 2,
            ),
            TextField(
              controller: latController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            TextField(
              controller: longController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Ganti Gambar'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedImage != null
                        ? basename(selectedImage!.path)
                        : 'Tidak ada gambar baru',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.point.imageUrl != null && selectedImage == null)
              Image.network(widget.point.imageUrl!, height: 120),

            if (selectedImage != null)
              Image.file(selectedImage!, height: 120),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _updatePoint,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
