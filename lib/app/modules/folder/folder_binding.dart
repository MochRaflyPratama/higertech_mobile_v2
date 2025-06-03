import 'package:get/get.dart';
import 'folder_controller.dart';

class FolderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FolderController>(() => FolderController());
  }
}
