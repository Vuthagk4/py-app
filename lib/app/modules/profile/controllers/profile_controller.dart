import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';
class ProfileController extends GetxController {
  var userName = "Loading...".obs;
  var userEmail = "Loading...".obs;
  var userImage = "".obs;
  var orderCount = "0".obs;
  var isDarkMode = false.obs;
  var isUploading = false.obs;

  final _imagePicker = ImagePicker();
  final _provider = Get.find<APIProvider>();

  @override
  void onInit() {
    super.onInit();
    getUserData();
    fetchOrderStats();
    loadThemeStatus();
  }

  // 🟢 FIXED: Combined and only one getImageUrl method
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg";
    }

    String finalPath = path;

    // Handle Emulator vs Real Device IP for CentOS 9
    if (Platform.isAndroid) {
      finalPath = finalPath
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }

    // Ensure path points to your Laravel storage folder
    if (!finalPath.startsWith('http')) {
      // Use your Laptop IP here if testing on a real Android 11 phone
      finalPath = "http://10.0.2.2:8000/storage/$finalPath";
    }

    return finalPath;
  }

  void getUserData() async {
    try {
      // 🟢 1. Clear the image cache so the old photo is forgotten
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      final dynamic userData = await StorageService.read(key: 'user');
      if (userData != null) {
        Map<String, dynamic> user = userData is String ? jsonDecode(userData) : userData;

        userName.value = user['name']?.toString() ?? "Unknown";
        userEmail.value = user['email']?.toString() ?? "";

        // 🟢 2. The Cache-Buster: Append a unique ID to the end of the URL
        String rawImage = user['image']?.toString() ?? user['avatar']?.toString() ?? "";
        if (rawImage.isNotEmpty) {
          userImage.value = "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}";
        } else {
          userImage.value = "";
        }
      }
    } catch (e) {
      print("Refresh Error: $e");
    }
  }

  Future<void> pickAndUploadAvatar() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50
      );

      if (file != null) {
        isUploading.value = true;
        final response = await _provider.updateProfile(
          name: userName.value,
          avatar: File(file.path),
        );

        if (response.statusCode == 200) {
          // Clear internal image cache to force reload
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();

          var updatedUser = response.data['user'];
          await StorageService.write(key: 'user', value: jsonEncode(updatedUser));
          getUserData();

          Get.snackbar("Success", "Profile updated successfully!",
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Could not upload image to server.");
    } finally {
      isUploading.value = false;
    }
  }

  // 🟢 4. Theme Management
  void loadThemeStatus() async {
    final String? status = await StorageService.read(key: 'isDarkMode');
    isDarkMode.value = status == 'true';
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await StorageService.write(key: 'isDarkMode', value: value.toString());
  }

  // 🟢 Updated: Fetch Stats with better data parsing
  Future<void> fetchOrderStats() async {
    try {
      final response = await _provider.getOrders();
      if (response.statusCode == 200) {
        var responseData = response.data;
        List orders = [];

        // Check if Laravel returns { "data": [...] } or just [...]
        if (responseData is Map && responseData.containsKey('data')) {
          orders = responseData['data'];
        } else if (responseData is List) {
          orders = responseData;
        }

        orderCount.value = orders.length.toString();
        print("Order Count Updated: ${orderCount.value}"); // Debug log
      }
    } catch (e) {
      print("Error fetching order count: $e");
      orderCount.value = "0";
    }
  }
  void refreshProfile() {
    getUserData();
    fetchOrderStats();
  }

  void logout() async {
    await StorageService.delete(key: 'user');
    await StorageService.delete(key: 'token');
    Get.offAllNamed('/login'); // Return to login screen
  }
}