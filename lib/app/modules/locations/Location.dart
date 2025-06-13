import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:projectv2/app/modules/CRUD/data.dart';
import 'package:projectv2/app/services/auth_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(-6.917464, 107.619123);
  final Map<MarkerId, Marker> _markers = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setCurrentLocation();
      _fetchMarkersFromAPI();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    // mapController?.dispose();
    super.dispose();
  }

  Future<void> _setCurrentLocation({bool moveCamera = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    try {
  Position position = await Geolocator.getCurrentPosition();
  // ...
} catch (e) {
  print('Error getting location: $e');
}

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
    if (!_isDisposed) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
    if (moveCamera && mapController != null) {
      mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  Future<void> _fetchMarkersFromAPI({bool moveToFirstMarker = false}) async {
    final url = Uri.parse('http://10.0.2.2:5101/api/mappoints');
    final token = await AuthService.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final Map<MarkerId, Marker> fetchedMarkers = {};

      for (var item in data) {
        final lat = double.tryParse(item['latitude'].toString());
        final lng = double.tryParse(item['longitude'].toString());
        if (lat == null || lng == null) continue;

        final id = MarkerId(item['id'].toString());
        final marker = Marker(
          markerId: id,
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: item['title'] ?? 'Marker',
            snippet: item['description'] ?? '',
          ),
        );
        fetchedMarkers[id] = marker;
      }

      print('Jumlah marker dimuat: ${fetchedMarkers.length}');
      if (!_isDisposed) {
        setState(() {
          _markers.clear();
          _markers.addAll(fetchedMarkers);
        });
        if (moveToFirstMarker && fetchedMarkers.isNotEmpty) {
          final lastMarker = fetchedMarkers.values.last;
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: lastMarker.position, zoom: 17),
            ),
          );
        }
      }

      // ⛳ Fokus ke semua marker (agar tidak di luar layar)
      if (mapController != null && fetchedMarkers.isNotEmpty) {
        final bounds = _createBounds(
          fetchedMarkers.values.map((m) => m.position).toList(),
        );
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } else {
      print('Gagal memuat marker: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }

  Future<void> _onLongPress(LatLng position) async {
    final bool? isSaved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationFormPage(position: position),
      ),
    );

    if (isSaved == true) {
      await _fetchMarkersFromAPI(
        moveToFirstMarker: true,
      ); // Re-fetch markers setelah simpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi baru disimpan dan marker diperbarui')),
      );
    }
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    final southwestLng = positions
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    final northeastLat = positions
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    final northeastLng = positions
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  /// Fungsi baru untuk refresh: update lokasi user, ambil marker, lalu pindahkan kamera ke lokasi user
  Future<void> _refreshMap() async {
    await _setCurrentLocation(moveCamera: true);
    await _fetchMarkersFromAPI();
    if (!_isDisposed && mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps',                    
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
              ),
            ),
        backgroundColor: const Color(0xFF2D2E49),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white,),
            onPressed: () async {
              await _refreshMap();
              if (!_isDisposed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Peta dan marker berhasil diperbarui'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) => mapController = controller,
        onLongPress: _onLongPress,
        markers: Set<Marker>.of(_markers.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
