import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projectv2/app/modules/CRUD/data.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({Key? key}) : super(key: key);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLatLng = LatLng(pos.latitude, pos.longitude);
        _marker = Marker(
          markerId: const MarkerId('selected'),
          position: _selectedLatLng!,
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() => _selectedLatLng = newPosition);
          },
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }
  }

void _confirmLocation() {
  if (_selectedLatLng != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDataPage(
          latitude: _selectedLatLng!.latitude,
          longitude: _selectedLatLng!.longitude,
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmLocation,
          )
        ],
      ),
      body: _selectedLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLatLng!,
                zoom: 16,
              ),
              markers: {_marker!},
              onMapCreated: (controller) => _mapController = controller,
            ),
    );
  }
}
