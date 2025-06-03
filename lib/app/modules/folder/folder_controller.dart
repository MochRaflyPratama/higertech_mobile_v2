import 'package:get/get.dart';
import 'folder_model.dart';
import 'folder_provider.dart';

class FolderController extends GetxController {
  var fileList = <FolderItemModel>[].obs;
  var isLoading = true.obs;

  final FolderProvider _provider = FolderProvider();

  @override
  void onInit() {
    fetchFiles();
    super.onInit();
  }

  void fetchFiles() async {
    try {
      isLoading.value = true;
      fileList.value = await _provider.fetchUploadedFiles();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data');
    } finally {
      isLoading.value = false;
    }
  }
}
