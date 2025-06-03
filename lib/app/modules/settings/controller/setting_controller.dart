import 'package:get/get.dart';

class SettingsController extends GetxController {
  void logout() {
    // Tambahkan logika logout di sini, misalnya hapus token atau navigasi ke login screen
    Get.offAllNamed('/login');
  }
}
