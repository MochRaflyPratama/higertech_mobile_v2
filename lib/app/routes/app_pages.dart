import 'package:get/get.dart';
import 'package:projectv2/app/modules/folder/folder_binding.dart';
import 'package:projectv2/app/modules/folder/folder_view.dart';
import 'package:projectv2/app/modules/home/Homescreen.dart';
import 'package:projectv2/app/modules/locations/tag/taglocation.dart';
import 'package:projectv2/app/modules/settings/controller/setting_controller.dart';
import 'package:projectv2/app/modules/settings/settingscreen.dart';
import 'package:projectv2/app/routes/app_route.dart';
import 'package:projectv2/app/screens/login/login_screen.dart';
import 'package:projectv2/app/screens/splash/splash_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Homepage(),
    ),
    GetPage(
      name: AppRoutes.location,
      page: () => const LocationPickerPage(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.folder,
      page: () => const FolderView(),
      binding: FolderBinding(),
    ),
  ];
}
