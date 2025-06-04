import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projectv2/app/modules/CRUD/data.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(-7.797068, 110.370529); // Default Yogyakarta
  final Map<MarkerId, Marker> _markers = {};
  // final int userId = 123; // Jika ingin tetap pakai userId, bisa tetap digunakan

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  Future<void> _onLongPress(LatLng position) async {
    // Navigasi ke form, tunggu hasilnya
    final bool? isSaved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationFormPage(position: position),
      ),
    );

    // Jika user menyimpan data (misal return true), baru tambahkan marker
    if (isSaved == true) {
      _addMarker(position);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Lokasi disimpan: ${position.latitude}, ${position.longitude}',
        ),
      ));
    }
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(DateTime.now().toIso8601String());
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: 'Titik Marker',
        snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
      ),
      onTap: () {
        // Jika ingin menghapus marker saat di-tap, aktifkan kode di bawah ini:
        // setState(() {
        //   _markers.remove(markerId);
        // });
      },
    );
    setState(() {
      _markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onLongPress: _onLongPress,
            markers: Set<Marker>.of(_markers.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
        ],
      ),
      // Tidak perlu floatingActionButton, marker langsung muncul setelah simpan
    );
  }
}