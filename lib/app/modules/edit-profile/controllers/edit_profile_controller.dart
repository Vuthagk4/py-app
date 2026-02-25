import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';
import '../../profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final _provider = Get.find<APIProvider>();
  final _imagePicker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  var isLoading = false.obs;
  var currentImageUrl = ''.obs;
  var newProfileImgPath = ''.obs;
  File? newProfileImg;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
  }

  void loadCurrentUserData() async {
    try {
      final dynamic userData = await StorageService.read(key: 'user');
      if (userData != null) {
        Map<String, dynamic> user = {};
        if (userData is String) {
          user = Map<String, dynamic>.from(jsonDecode(userData));
        } else if (userData is Map) {
          user = Map<String, dynamic>.from(userData);
        }

        nameController.text = user['name']?.toString() ?? '';
        emailController.text = user['email']?.toString() ?? '';

        // 🔴 FIX: Add timestamp to force UI refresh when loading the screen
        String rawImage = user['image']?.toString() ?? user['avatar']?.toString() ?? '';
        currentImageUrl.value = rawImage.isNotEmpty ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}" : "";
      }
    } catch (e) {
      print("Error loading user data in Edit Profile: $e");
    }
  }

  void pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      newProfileImg = File(file.path);
      newProfileImgPath.value = file.path;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      final response = await _provider.updateProfile(
        name: nameController.text,
        avatar: newProfileImg,
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

        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getUserData();
        }

        Get.back(result: true); // Pass result back to trigger refresh explicitly
        Get.snackbar("Success", "Profile updated successfully!", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Failed to update profile.");
      }
    } catch (e) {
      Get.snackbar("Error", "Network or server error occurred.");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}