import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  static const LatLng _pnhCenter = LatLng(11.5564, 104.9282);
  LatLng _draggedLocation = _pnhCenter;
  String _currentAddressName = "Locating...";
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _getAddressFromCoords(_pnhCenter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoords(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String street = place.street ?? "";
        String subLocality = place.subLocality ?? "";
        String city = place.administrativeArea ??
            place.locality ?? "Phnom Penh";
        String address = [street, subLocality, city]
            .where((e) => e.isNotEmpty)
            .join(", ");
        setState(() {
          _currentAddressName = address.isNotEmpty
              ? address
              : "Lat: ${position.latitude.toStringAsFixed(6)}, "
              "Lng: ${position.longitude.toStringAsFixed(6)}";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddressName =
        "Lat: ${position.latitude.toStringAsFixed(6)}, "
            "Lng: ${position.longitude.toStringAsFixed(6)}";
      });
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _handleSearch() async {
    if (_searchController.text.isEmpty) return;
    try {
      List<Location> locations =
      await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        final newPos = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPos, zoom: 17),
          ),
        );
        _draggedLocation = newPos;
        await _getAddressFromCoords(newPos);
      }
    } catch (e) {
      Get.snackbar("Search", "Location not found.",
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final currentPos = LatLng(position.latitude, position.longitude);
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentPos, zoom: 18),
        ),
      );
      _draggedLocation = currentPos;
      await _getAddressFromCoords(currentPos);
    } catch (e) {
      Get.snackbar("Error", "Could not get current location.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            const CameraPosition(target: _pnhCenter, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: (pos) => _draggedLocation = pos.target,
            onCameraIdle: () => _getAddressFromCoords(_draggedLocation),
          ),

          // Center Pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(Icons.location_on,
                  size: 55, color: Color(0xFF2563EB)),
            ),
          ),

          // Search Bar
          Positioned(
            top: 60, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _handleSearch(),
                      decoration: const InputDecoration(
                        hintText: "Search location...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
                    onPressed: _handleSearch,
                  ),
                ],
              ),
            ),
          ),

          // Address Preview
          Positioned(
            top: 130, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_pin,
                      color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _isLoadingAddress
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      _currentAddressName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GPS Button
          Positioned(
            bottom: 110, right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location,
                  color: Color(0xFF2563EB)),
            ),
          ),

          // ✅ Confirm Button
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back(result: {
                  'location': _draggedLocation,
                  'address': _currentAddressName.isNotEmpty &&
                      _currentAddressName != "Locating..."
                      ? _currentAddressName
                      : "Lat: ${_draggedLocation.latitude.toStringAsFixed(6)}, "
                      "Lng: ${_draggedLocation.longitude.toStringAsFixed(6)}",
                });
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                "Confirm Location",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}