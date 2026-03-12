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
  bool _isSearching = false;

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

  // ✅ Returns Khmer address names when available
  Future<void> _getAddressFromCoords(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      List<Placemark> placemarks = [];

      // Try Khmer locale first for display
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        // Fallback to English
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String street = place.street ?? "";
        String subLocality = place.subLocality ?? "";
        String city = place.administrativeArea ?? place.locality ?? "Phnom Penh";
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

  // ✅ 3-strategy search supporting Khmer text
  Future<void> _handleSearch() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() => _isSearching = true);

    try {
      List<Location> locations = [];

      // Strategy 1: Khmer locale
      try {
        locations = await locationFromAddress(
          _searchController.text.trim(),
        );
      } catch (_) {}

      // Strategy 2: Append "Cambodia" hint
      if (locations.isEmpty) {
        try {
          locations = await locationFromAddress(
            "${_searchController.text.trim()}, Cambodia",
          );
        } catch (_) {}
      }

      // Strategy 3: Plain fallback
      if (locations.isEmpty) {
        try {
          locations = await locationFromAddress(_searchController.text.trim());
        } catch (_) {}
      }

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
        // Dismiss keyboard
        FocusScope.of(context).unfocus();
      } else {
        Get.snackbar(
          "រកមិនឃើញ / Not Found",
          "សូមបញ្ចូល 'កម្ពុជា' នៅខាងក្រោយ\nTry adding 'Cambodia' at the end",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.fromLTRB(20, 80, 20, 0),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Search failed. Try in English or add 'Cambodia'",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.fromLTRB(20, 80, 20, 0),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permission Denied",
          "Please enable location in Settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
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
      Get.snackbar(
        "Error",
        "Could not get current location.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────
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

          // ── Center Pin ──────────────────────────────────────────────
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_on,
                size: 55,
                color: Color(0xFFFF5252),
                shadows: [Shadow(color: Colors.black38, blurRadius: 10)],
              ),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────────────
          Positioned(
            top: 55,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: Color(0xFFFF5252), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _handleSearch(),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "ស្វែងរកទីតាំង / Search location...",
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_isSearching)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5252),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _handleSearch,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Address Preview Card ────────────────────────────────────
          Positioned(
            top: 130,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_pin,
                          color: Color(0xFFFF5252), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isLoadingAddress
                          ? Row(
                        children: [
                          const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "កំពុងស្វែងរក...",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      )
                          : Text(
                        _currentAddressName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── GPS / My Location Button ────────────────────────────────
          Positioned(
            bottom: 120,
            right: 16,
            child: GestureDetector(
              onTap: _goToCurrentLocation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: Color(0xFFFF5252), size: 24),
              ),
            ),
          ),

          // ── Confirm Button ──────────────────────────────────────────
          Positioned(
            bottom: 36,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back(result: {
                  'location': _draggedLocation,
                  'address': _currentAddressName.isNotEmpty &&
                      _currentAddressName != "Locating..." &&
                      _currentAddressName != "កំពុងស្វែងរក..."
                      ? _currentAddressName
                      : "Lat: ${_draggedLocation.latitude.toStringAsFixed(6)}, "
                      "Lng: ${_draggedLocation.longitude.toStringAsFixed(6)}",
                });
              },
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: const Text(
                "បញ្ជាក់ទីតាំង / Confirm Location",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: const Color(0x55FF5252),
              ),
            ),
          ),
        ],
      ),
    );
  }
}