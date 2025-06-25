import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projectv2/app/routes/app_route.dart';
import 'package:projectv2/app/services/auth_service.dart'; // ⬅️ pastikan ini di-import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // ⬅️ Ganti Future.delayed dengan pengecekan login
  }

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // biar splash terlihat sebentar

    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home); // langsung ke homepage
    } else {
      Get.offAllNamed(AppRoutes.login); // arahkan ke login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C44),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/LogoHigertrack.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              "Bapenda Kalteng 1",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
