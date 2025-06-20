import 'package:get/get.dart';
import 'package:projectv2/app/modules/folder/folder_model.dart';
import 'package:projectv2/app/modules/folder/folder_repository.dart';
import 'package:projectv2/app/services/auth_service.dart';

class FolderController extends GetxController {
  final FolderRepository repository;

  FolderController(this.repository);

  var isLoading = true.obs;
  var mapPoints = <FolderItemModel>[].obs;

  @override
  void onInit() {
    fetchPoints();
    super.onInit();
  }

  void fetchPoints() async {
    try {
      isLoading(true);

      final result = await repository.fetchMapPoints(); // Ambil semua data
      final user = await AuthService.getCurrentUser();
      final userId = user?.id?.toLowerCase().trim();
      final role = user?.role?.toLowerCase().trim();

      print("🔍 Current User ID: $userId, role: $role");

      // Filter berdasarkan role
      final filtered =
          role == 'admin'
              ? result
              : result
                  .where((p) => p.createdBy?.toLowerCase().trim() == userId)
                  .toList();

      mapPoints.assignAll(filtered);
    } catch (e) {
      print('❌ Error saat fetch: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void deleteMapPoint(int id) async {
    try {
      isLoading(true);
      await repository.deleteMapPoint(id); // Panggil repository delete
      fetchPoints(); // Refresh list
      Get.snackbar('Berhasil', 'Data berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus data: $e');
    } finally {
      isLoading(false);
    }
  }

  void updateMapPoint(FolderItemModel updatedPoint) async {
    try {
      isLoading(true);
      await repository.updateMapPoint(updatedPoint);
      fetchPoints();
      Get.snackbar('Sukses', 'Data berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', 'Gagal update: $e');
    } finally {
      isLoading(false);
    }
  }
}
