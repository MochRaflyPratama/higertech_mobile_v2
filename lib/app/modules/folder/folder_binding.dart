import 'package:get/get.dart';
import 'package:projectv2/app/modules/folder/folder_controller.dart';
import 'package:projectv2/app/modules/folder/folder_repository.dart';

class FolderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FolderRepository());
    Get.lazyPut(() => FolderController(Get.find()));
  }
}
