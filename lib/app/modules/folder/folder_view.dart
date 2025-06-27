import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectv2/app/modules/folder/edit/edit_folder_view.dart';
import 'package:projectv2/app/modules/folder/folder_controller.dart';

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FolderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map Points',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
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
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header image with onTap to fullscreen
                          GestureDetector(
                            onTap: () {
                              if (point.imageUrl != null) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => Dialog(
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.black,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  point.imageUrl!,
                                                  fit: BoxFit.contain,
                                                  errorBuilder:
                                                      (
                                                        _,
                                                        __,
                                                        ___,
                                                      ) => const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 80,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 30,
                                              right: 20,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child:
                                  point.imageUrl != null
                                      ? Image.network(
                                        point.imageUrl!,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              width: double.infinity,
                                              height: 180,
                                              color: Colors.grey.shade100,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      )
                                      : Container(
                                        width: double.infinity,
                                        height: 180,
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),
                          ),

                          // Detail content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (point.title != null &&
                                    point.title!.isNotEmpty)
                                  Text(
                                    point.title!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF2D2E49),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                if (point.description != null &&
                                    point.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      point.description!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${point.latitude}, ${point.longitude}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(height: 1, color: Colors.grey.shade200),
                                const SizedBox(height: 10),
                                if (point.createdUserName != null &&
                                    point.createdUserName!.isNotEmpty)
                                  Text(
                                    'Created by ${point.createdUserName}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                Text(
                                  point.createdAt != null
                                      ? point.createdAt.toString()
                                      : '',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          point.imageUrl != null
                              ? Image.network(
                                point.imageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 24,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                              : Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.title ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            point.description ?? '-',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Color(0xFF5B8DEF),
                          ),
                          onPressed: () {
                            Get.to(() => EditFolderView(point: point));
                          },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Color(0xFFE57373),
                          ),
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Konfirmasi',
                              content: const Text(
                                'Yakin ingin menghapus data ini?',
                              ),
                              textCancel: 'Batal',
                              textConfirm: 'Hapus',
                              confirmTextColor: Colors.white,
                              onConfirm: () {
                                controller.deleteMapPoint(point.id);
                                Get.back();
                              },
                            );
                          },
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
