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
        Map<String, dynamic> user = userData is String ? jsonDecode(userData) : userData;
        nameController.text = user['name']?.toString() ?? '';
        emailController.text = user['email']?.toString() ?? '';

        String rawImage = user['image']?.toString() ?? user['avatar']?.toString() ?? '';
        // 🟢 Force initial reload of the image
        currentImageUrl.value = rawImage.isNotEmpty ? "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}" : "";
      }
    } catch (e) {
      print("Error: $e");
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
        // 🟢 STEP 1: Wipe the local image cache
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        Map<String, dynamic> updatedUser = response.data['user'];

        // Preserve email
        final dynamic oldData = await StorageService.read(key: 'user');
        if (oldData != null) {
          Map<String, dynamic> oldUser = oldData is String ? jsonDecode(oldData) : oldData;
          updatedUser['email'] = oldUser['email'];
        }

        // 🟢 STEP 2: Save updated user and notify ProfileController
        await StorageService.write(key: 'user', value: jsonEncode(updatedUser));

        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getUserData();
        }

        Get.back(result: true); // Return to ProfileView
        Get.snackbar("Success", "Profile updated!", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }
}