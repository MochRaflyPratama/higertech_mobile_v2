import 'package:get/get.dart';
import 'package:projectv2/app/modules/folder/folder_model.dart';
import 'package:projectv2/app/modules/folder/folder_repository.dart';

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
      final result = await repository.fetchMapPoints();
      mapPoints.assignAll(result);
    } catch (e) {
      print('Error saat fetch: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void deleteMapPoint(int id) async {
    try {
      isLoading(true);
      await repository.deleteMapPoint(id); // Pastikan ada method ini di repository
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
