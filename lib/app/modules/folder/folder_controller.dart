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
}
