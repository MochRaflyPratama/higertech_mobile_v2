import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectv2/app/modules/folder/folder_controller.dart';

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FolderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Points'),
        backgroundColor: const Color(0xFF2D2E49),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.mapPoints.isEmpty) {
          return const Center(child: Text('Tidak ada data MapPoint.'));
        }

        return ListView.builder(
          itemCount: controller.mapPoints.length,
          itemBuilder: (context, index) {
            final point = controller.mapPoints[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: point.imageUrl != null
                    ? Image.network(
                        point.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(point.title ?? 'No Title'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deskripsi: ${point.description ?? "-"}'),
                    Text('Latitude: ${point.latitude}'),
                    Text('Longitude: ${point.longitude}'),
                  ],
                ),
                onTap: () {
                  Get.defaultDialog(
                    title: point.title ?? 'Detail',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deskripsi: ${point.description ?? "-"}'),
                        Text('Latitude: ${point.latitude}'),
                        Text('Longitude: ${point.longitude}'),
                        Text('Created at: ${point.createdAt}'),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
