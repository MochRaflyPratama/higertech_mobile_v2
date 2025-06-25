import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_route.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  void _openMapFromLocation() async {
    final result = await Get.toNamed(AppRoutes.location);
    if (result != null && result is Map<String, double>) {
      final lat = result['lat']!.toString();
      final lng = result['lng']!.toString();
      Get.snackbar('Lokasi Dipilih', 'Picked: $lat, $lng');
    }
  }

  void _showAppVersionDialog() {
    Get.defaultDialog(
      title: "Tentang Aplikasi",
      content: const Text("Versi 1.0.0\nHigertrack App"),
      textConfirm: "Tutup",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2E49),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Logo di atas
            Center(
              child: Image.asset(
                'assets/images/LogoHigertrack.png',
                width: 80,
              ),
            ),
            const SizedBox(height: 30),

            // Menu list vertikal
            _MenuItem(
              icon: Icons.map,
              label: 'Peta',
              onTap: _openMapFromLocation,
            ),
             _MenuItem(
              icon: Icons.folder,
              label: 'Folder',
              onTap: () => Get.toNamed(AppRoutes.folder),
            ),
            _MenuItem(
              icon: Icons.settings,
              label: 'Pengaturan',
              onTap: () => Get.toNamed(AppRoutes.settings),
            ),
           

            const Spacer(),
            GestureDetector(
              onTap: _showAppVersionDialog,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Colors.white70),
                  SizedBox(width: 5),
                  Text(
                    "Versi 1.0.0",
                    style: TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
