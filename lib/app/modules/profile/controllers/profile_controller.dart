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

  final _imagePicker = ImagePicker();
  var isUploading = false.obs;
  final _provider = Get.find<APIProvider>();

  @override
  void onInit() {
    super.onInit();
    getUserData();
    fetchOrderStats();
    loadThemeStatus();
  }

  void loadThemeStatus() async {
    try {
      // FlutterSecureStorage always returns a String?
      final String? status = await StorageService.read(key: 'isDarkMode');

      // Default to false if null, otherwise parse the string
      bool darkModeActive = status == 'true';

      isDarkMode.value = darkModeActive;

      // Apply theme mode defined in your main.dart
      Get.changeThemeMode(darkModeActive ? ThemeMode.dark : ThemeMode.light);

    } catch (e) {
      print("Theme Loading Error: $e");
      isDarkMode.value = false;
    }
  }

  void toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

    // 🟢 StorageService.write now handles the bool-to-string conversion
    await StorageService.write(key: 'isDarkMode', value: value);
  }



  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg";
    }
    if (path.startsWith("http") && Platform.isAndroid) {
      return path.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    }
    return path;
  }

  Future<void> fetchOrderStats() async {
    try {
      String? token = await StorageService.read(key: 'token');
      if (token == null) return;

      final response = await _provider.getOrders();

      if (response.statusCode == 200 && response.data != null) {
        List orders = [];
        // Handle Laravel 'data' wrapper or direct list
        if (response.data is List) {
          orders = response.data;
        } else if (response.data is Map && response.data['data'] is List) {
          orders = response.data['data'];
        }
        orderCount.value = orders.length.toString();
      }
    } catch (e) {
      orderCount.value = "0";
    }
  }

  void getUserData() async {
    try {
      final dynamic userData = await StorageService.read(key: 'user');
      if (userData != null) {
        Map<String, dynamic> user = {};
        if (userData is String) {
          user = Map<String, dynamic>.from(jsonDecode(userData));
        } else if (userData is Map) {
          user = Map<String, dynamic>.from(userData);
        }

        userName.value = user['name']?.toString() ?? "Unknown User";
        userEmail.value = user['email']?.toString() ?? "No email provided";

        // 🟢 Cache-busting: Forces Flutter to ignore previous image cache
        String rawImage = user['image']?.toString() ?? user['avatar']?.toString() ?? "";
        userImage.value = rawImage.isNotEmpty
            ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}"
            : "";
      }
    } catch (e) {
      userName.value = "Guest";
    }
  }

  void pickAndUploadAvatar() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        isUploading.value = true;
        File imageFile = File(file.path);

        final response = await _provider.updateProfile(
          name: userName.value,
          avatar: imageFile,
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> updatedUser = response.data['user'];
          // Preserve email if not returned by update API
          final dynamic oldData = await StorageService.read(key: 'user');
          if (oldData != null) {
            Map<String, dynamic> oldUser = Map<String, dynamic>.from(
                oldData is String ? jsonDecode(oldData) : oldData
            );
            updatedUser['email'] = oldUser['email'];
          }

          await StorageService.write(key: 'user', value: jsonEncode(updatedUser));

          // Refresh UI with new image timestamp
          String rawImage = updatedUser['avatar'] ?? updatedUser['image'] ?? '';
          userImage.value = rawImage.isNotEmpty
              ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}"
              : "";

          Get.snackbar("Success", "Profile updated!");
        }
      }
    } finally {
      isUploading.value = false;
    }
  }

  void logout() async {
    await StorageService.delete(key: 'user');
    await StorageService.delete(key: 'token');
    Get.offAllNamed('/login');
  }
}