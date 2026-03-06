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

  // 🟢 FIXED: Added Null-Safety for 'city' and 'subLocality'
  Future<void> _getAddressFromCoords(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Use '??' to provide empty strings if a field is null
          String street = place.street ?? "";
          String subLocality = place.subLocality ?? "";
          String city = place.administrativeArea ?? place.locality ?? "Phnom Penh";

          _currentAddressName = "$street, $subLocality, $city".replaceAll(", ,", ",");
        });
      }
    } catch (e) {
      setState(() => _currentAddressName = "Unknown Location");
    }
  }

  Future<void> _handleSearch() async {
    if (_searchController.text.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(locations.first.latitude, locations.first.longitude), zoom: 17),
        ));
      }
    } catch (e) {
      Get.snackbar("Search", "Location not found.");
    }
  }

  Future<void> _goToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _pnhCenter, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: (pos) => _draggedLocation = pos.target,
            onCameraIdle: () => _getAddressFromCoords(_draggedLocation),
          ),

          // Search Bar
          Positioned(
            top: 60, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _handleSearch(),
                decoration: const InputDecoration(hintText: "Search location...", border: InputBorder.none, icon: Icon(Icons.search, color: Color(0xFF2563EB))),
              ),
            ),
          ),

          // Address Preview Box
          Positioned(
            top: 130, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Text(_currentAddressName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),

          const Center(child: Padding(padding: EdgeInsets.only(bottom: 35), child: Icon(Icons.location_on, size: 55, color: Color(0xFF2563EB)))),

          // My Location Button
          Positioned(bottom: 110, right: 20, child: FloatingActionButton(backgroundColor: Colors.white, mini: true, onPressed: _goToCurrentLocation, child: const Icon(Icons.my_location, color: Color(0xFF2563EB)))),

          Positioned(
            bottom: 40, left: 20, right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => Get.back(result: {'location': _draggedLocation, 'address': _currentAddressName}),
              child: const Text("CONFIRM DELIVERY SPOT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}