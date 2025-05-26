import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:projectv2/app/modules/camera/Camerascreen.dart';

class CreateDataPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const CreateDataPage({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<CreateDataPage> createState() => _CreateDataPageState();
}

class _CreateDataPageState extends State<CreateDataPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  File? selectedImage; // Gambar yang dipilih dari kamera

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Tambah Lokasi'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // Supaya bisa discroll kalau form panjang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Point'),
              ),
              const SizedBox(height: 16),
              Text('Koordinat: ${widget.latitude}, ${widget.longitude}'),
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
                        MaterialPageRoute(
                          builder: (_) => ImagePickerScreen(),
                        ),
                      );

                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    child: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
 if (selectedImage != null)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
       GestureDetector(
        onTap: () {
          showImageViewer(
            context,
            Image.file(selectedImage!).image,
            swipeDismissible: true,
            doubleTapZoomable: true,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            selectedImage!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {
            setState(() {
              selectedImage = null;
            });
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text("Hapus", style: TextStyle(color: Colors.red)),
        ),
      )
    ],
  ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text;
                  final desc = descController.text;

                  // Simpan data atau kirim ke server di sini (termasuk file foto jika perlu)

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Disimpan: $name di (${widget.latitude}, ${widget.longitude}) - $desc',
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
