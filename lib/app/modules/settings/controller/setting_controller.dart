import 'package:get/get.dart';
import 'package:projectv2/app/services/auth_service.dart';

class SettingsController extends GetxController {
  var userFullName = ''.obs;
  var userEmail = ''.obs;
  var userRole = ''.obs; // Tambahkan role

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      userFullName.value = user.fullName ?? '';
      userEmail.value = user.email ?? '';
      userRole.value = user.role ?? ''; // Ambil role
    }
  }

  void logout() async {
    await AuthService.logout();
    Get.offAllNamed('/login');
  }
}
