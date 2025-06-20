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
    super.dispose();
  }

  Future<void> _setCurrentLocation({bool moveCamera = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    try {
      Position position = await Geolocator.getCurrentPosition();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          return;
        }
      }

      if (!_isDisposed) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }

      if (moveCamera && mapController != null) {
        mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Ambil info user (role & userId) dari AuthService
  Future<Map<String, String?>> _getUserInfo() async {
    final user = await AuthService.getCurrentUser();
    debugPrint("DEBUG USER: ${user?.id} | ${user?.role}");
    return {'role': user?.role, 'email': user?.email, 'userId': user?.id};
  }

  /// Ambil data marker dari API dan filter sesuai role user
  Future<void> _fetchMarkersFromAPI({bool moveToFirstMarker = false}) async {
    final url = Uri.parse('http://103.183.75.71:5101/api/mappoints');
    final token = await AuthService.getAccessToken();
    final userInfo = await _getUserInfo();

    final userRole = (userInfo['role'] ?? '').toLowerCase().trim();
    final userId = (userInfo['userId'] ?? '').toLowerCase().trim();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<MarkerId, Marker> fetchedMarkers = {};
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
        debugPrint('⚠️ Format JSON tidak sesuai');
        return;
      }

      final List<dynamic> data = decoded['data'];

      // 🔐 Filter data berdasarkan role
      final filteredData =
          userRole == 'admin'
              ? data
              : data.where((item) {
                final markerOwnerId =
                    (item['createdBy'] ?? '').toString().toLowerCase().trim();
                return markerOwnerId == userId;
              }).toList();

      for (var item in filteredData) {
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

      if (mapController != null && fetchedMarkers.isNotEmpty) {
        final bounds = _createBounds(
          fetchedMarkers.values.map((m) => m.position).toList(),
        );
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } else {
      debugPrint('❌ Gagal memuat marker: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
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
      await _fetchMarkersFromAPI(moveToFirstMarker: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi baru disimpan dan marker diperbarui'),
        ),
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

  Future<void> _refreshMap() async {
    await _setCurrentLocation(moveCamera: false);
    await _fetchMarkersFromAPI();
    if (!_isDisposed && mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Maps',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF2D2E49),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
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
