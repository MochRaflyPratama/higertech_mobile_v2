import 'package:get/get.dart';
import 'package:projectv2/app/modules/settings/controller/setting_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
