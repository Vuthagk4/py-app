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

  final _imagePicker = ImagePicker();
  var isUploading = false.obs;
  final _provider = Get.find<APIProvider>();

  @override
  void onInit() {
    super.onInit();
    getUserData();
    fetchOrderStats();
  }
  Future<void> fetchOrderStats() async {
    try {
      // Only fetch if we have a token
      String? token = await StorageService.read(key: 'token');
      if (token == null) return;

      final response = await _provider.getOrders();
      if (response.statusCode == 200) {
        // Ensure data is a list before accessing length
        List orders = response.data is List ? response.data : [];
        orderCount.value = orders.length.toString();
      }
    } catch (e) {
      print("Order Stats Error: $e");
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

        // 🔴 FIX: Add timestamp so GetX triggers UI update and Flutter ignores cached image
        String rawImage = user['image']?.toString() ?? user['avatar']?.toString() ?? "";
        userImage.value = rawImage.isNotEmpty ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}" : "";

      } else {
        userName.value = "Guest";
        userEmail.value = "";
      }
    } catch (e) {
      print("CRITICAL parsing error in Profile: $e");
      userName.value = "Guest";
      userEmail.value = "";
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

          final dynamic oldData = await StorageService.read(key: 'user');
          if (oldData != null) {
            Map<String, dynamic> oldUser = Map<String, dynamic>.from(
                oldData is String ? jsonDecode(oldData) : oldData
            );
            updatedUser['email'] = oldUser['email'];
          }

          await StorageService.write(key: 'user', value: jsonEncode(updatedUser));

          // 🔴 FIX: Add timestamp here too!
          String rawImage = updatedUser['avatar'] ?? updatedUser['image'] ?? '';
          userImage.value = rawImage.isNotEmpty ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}" : "";

          Get.snackbar("Success", "Profile picture updated!", backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar("Error", "Failed to upload image.");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Could not upload image. Check your connection.");
      print(e);
    } finally {
      isUploading.value = false;
    }
  }

  void logout() async {
    try {
      await StorageService.delete(key: 'user');
      await StorageService.delete(key: 'token');

      Get.offAllNamed('/login');
      Get.snackbar("Success", "You have been successfully logged out.");
    } catch (e) {
      print("Logout error: $e");
    }
  }
}