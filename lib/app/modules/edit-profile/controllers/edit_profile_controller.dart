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
        Map<String, dynamic> user =
        userData is String ? jsonDecode(userData) : userData;
        nameController.text = user['name']?.toString() ?? '';
        emailController.text = user['email']?.toString() ?? '';

        String rawImage =
            user['image']?.toString() ?? user['avatar']?.toString() ?? '';

        // 🟢 Strip any existing ?v= timestamp before adding new one
        if (rawImage.contains('?v=')) {
          rawImage = rawImage.split('?v=')[0];
        }

        currentImageUrl.value = rawImage.isNotEmpty
            ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}"
            : "";
      }
    } catch (e) {
      print("loadCurrentUserData Error: $e");
    }
  }

  void pickImage() async {
    final file = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      newProfileImg = File(file.path);
      newProfileImgPath.value = file.path;
    }
  }

  Future<void> updateProfile() async {
    // 🟢 Validate name is not empty
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Validation", "Name cannot be empty",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 🟢 Show immediate feedback
      Get.snackbar("Saving...", "Updating your profile",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));

      final response = await _provider.updateProfile(
        name: nameController.text.trim(),
        avatar: newProfileImg,
      );

      // 🟢 Debug — print full response
      print("UPDATE PROFILE STATUS: ${response.statusCode}");
      print("UPDATE PROFILE DATA: ${response.data}");

      if (response.statusCode == 200) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        // 🟢 Safely extract user from response
        final responseData = response.data;
        Map<String, dynamic>? updatedUser;

        if (responseData is Map && responseData.containsKey('user')) {
          updatedUser = Map<String, dynamic>.from(responseData['user']);
        } else if (responseData is Map) {
          updatedUser = Map<String, dynamic>.from(responseData);
        }

        if (updatedUser != null) {
          // 🟢 Preserve email from old data
          final dynamic oldData = await StorageService.read(key: 'user');
          if (oldData != null) {
            Map<String, dynamic> oldUser =
            oldData is String ? jsonDecode(oldData) : oldData;
            updatedUser['email'] ??= oldUser['email'];
          }

          // 🟢 Save updated user to storage
          await StorageService.write(
              key: 'user', value: jsonEncode(updatedUser));
        }

        // 🟢 Refresh ProfileController if registered
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().getUserData();
        }

        await Future.delayed(const Duration(milliseconds: 200));

        Get.snackbar("Success ✅", "Profile updated!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));

        Get.back(result: true);

      } else {
        // 🟢 Show actual server error
        final errorMsg = response.data?['message'] ??
            response.data?.toString() ??
            "Server returned ${response.statusCode}";

        print("UPDATE PROFILE ERROR: $errorMsg");

        Get.snackbar("Update Failed", errorMsg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
      }
    } catch (e) {
      print("UPDATE PROFILE EXCEPTION: $e");
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4));
    } finally {
      isLoading.value = false;
    }
  }
}