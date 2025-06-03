import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'folder_controller.dart';

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    final FolderController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Files'),
        backgroundColor: const Color(0xFF2D2E49),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.fileList.isEmpty) {
          return const Center(child: Text('Belum ada file yang diunggah.'));
        }

        return ListView.builder(
          itemCount: controller.fileList.length,
          itemBuilder: (context, index) {
            final file = controller.fileList[index];
            return ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(file.fileName),
              subtitle: Text('Uploaded at: ${file.uploadedAt}'),
              onTap: () {
                // bisa pakai open url atau preview
                Get.snackbar('URL', file.url);
              },
            );
          },
        );
      }),
    );
  }
}
