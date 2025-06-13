import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Penting untuk Get.to() dan Get.toNamed()
import '../../routes/app_route.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  void _openMapFromLocation() async {
    // Dummy result untuk demonstrasi
    final result = await Get.toNamed(AppRoutes.location); // ganti jika pakai widget langsung

    if (result != null && result is Map<String, double>) {
      final lat = result['lat']!.toString();
      final lng = result['lng']!.toString();
      Get.snackbar('Lokasi Dipilih', 'Picked: $lat, $lng');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2D2E49),
      body: SafeArea(
        child: Stack(
          children: [
            // Lingkaran besar di kiri bawah
           Positioned(
              left: -screenWidth * 0.3,
              top: (MediaQuery.of(context).size.height - screenWidth * 0.9) / 2,
              child: Container(
                width: screenWidth * 0.8,
                height: screenWidth * 0.8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE0E0E0),
                ),
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.location), 
                  child:  Image.asset('assets/images/LogoHigertrack.png', fit: BoxFit.cover,),
                )
              ),
            ),


            // Ikon Map (atas tengah)
            Positioned(
              top: 70,
              left: screenWidth / 2 - 50,
              child: _buildIconButton(
                icon: Icons.map,
                size: 100,
                iconSize: 50,
                onTap: _openMapFromLocation,
              ),
            ),

            // Ikon Settings (kanan tengah)
            Positioned(
              top: screenHeight / 2 - 50,
              right: 30,
              child: _buildIconButton(
                icon: Icons.settings,
                size: 100,
                iconSize: 50,
                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
            ),

            // Ikon Folder (bawah tengah)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: _buildIconButton(
                icon: Icons.folder,
                size: 100,
                iconSize: 50,
                onTap: () {
                  Get.toNamed(AppRoutes.folder); 
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 80,
    double iconSize = 40,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE0E0E0),
        ),
        child: Icon(icon, size: iconSize, color: Colors.black),
      ),
    );
  }
}
