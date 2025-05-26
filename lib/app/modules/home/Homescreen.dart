import 'package:flutter/material.dart';
import 'package:projectv2/app/modules/locations/controller/locationController.dart';
import 'package:projectv2/app/modules/locations/tag/taglocation.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  void _openMapFromLocation(BuildContext context, String lat, String lng) {
    LocationController.openMap(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    String? lat;
    String? lng;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Higertech Tracking'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Pick Location on Map'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationPickerPage(),
                  ),
                );

                if (result != null && result is Map<String, double>) {
                  lat = result['lat']!.toString();
                  lng = result['lng']!.toString();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Picked: $lat, $lng')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
