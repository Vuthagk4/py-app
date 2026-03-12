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

  // ─── GET IMAGE URL ────────────────────────────────────────────────────────
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg";
    }

    String finalPath = path;

    if (Platform.isAndroid) {
      finalPath = finalPath
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }

    if (!finalPath.startsWith('http')) {
      finalPath = "http://10.0.2.2:8000/storage/$finalPath";
    }

    return finalPath;
  }

  // ─── GET USER DATA FROM STORAGE ───────────────────────────────────────────
  Future<void> getUserData() async {
    try {
      // ✅ Do NOT clear image cache here — only clear after real upload
      final dynamic userData = await StorageService.read(key: 'user');
      if (userData != null) {
        Map<String, dynamic> user =
        userData is String ? jsonDecode(userData) : userData;

        userName.value = user['name']?.toString() ?? "Unknown";
        userEmail.value = user['email']?.toString() ?? "";

        String rawImage = user['image']?.toString() ??
            user['avatar']?.toString() ??
            "";

        // ✅ No timestamp here — only set raw image path
        userImage.value = rawImage;
      }
    } catch (e) {
      print("getUserData Error: $e");
    }
  }

  // ─── PICK & UPLOAD AVATAR ─────────────────────────────────────────────────
  Future<void> pickAndUploadAvatar() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,   // ✅ good quality
        maxWidth: 512,      // ✅ resize before upload = much faster
        maxHeight: 512,
      );

      if (file != null) {
        isUploading.value = true;

        final response = await _provider.updateProfile(
          name: userName.value,
          avatar: File(file.path),
        );

        if (response.statusCode == 200) {
          var updatedUser = response.data['user'];

          // ✅ Save updated user to storage
          await StorageService.write(
              key: 'user', value: jsonEncode(updatedUser));

          // ✅ Only clear cache HERE after a real upload
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();

          // ✅ Add timestamp only after upload to force image refresh
          String rawImage = updatedUser['image']?.toString() ??
              updatedUser['avatar']?.toString() ??
              "";

          if (rawImage.isNotEmpty) {
            userImage.value =
            "$rawImage?v=${DateTime.now().millisecondsSinceEpoch}";
          } else {
            userImage.value = "";
          }

          // ✅ Update name and email directly from response
          userName.value =
              updatedUser['name']?.toString() ?? userName.value;
          userEmail.value =
              updatedUser['email']?.toString() ?? userEmail.value;

          Get.snackbar(
            "Success",
            "Profile updated successfully!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not upload image to server.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("pickAndUploadAvatar Error: $e");
    } finally {
      isUploading.value = false;
    }
  }

  // ─── THEME ────────────────────────────────────────────────────────────────
  void loadThemeStatus() async {
    final String? status = await StorageService.read(key: 'isDarkMode');
    isDarkMode.value = status == 'true';
    Get.changeThemeMode(
        isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await StorageService.write(
        key: 'isDarkMode', value: value.toString());
  }

  // ─── ORDER STATS ──────────────────────────────────────────────────────────
  Future<void> fetchOrderStats() async {
    try {
      final response = await _provider.getOrders();
      if (response.statusCode == 200) {
        var responseData = response.data;
        List orders = [];

        if (responseData is Map && responseData.containsKey('data')) {
          orders = responseData['data'];
        } else if (responseData is List) {
          orders = responseData;
        }

        orderCount.value = orders.length.toString();
      }
    } catch (e) {
      print("fetchOrderStats Error: $e");
      orderCount.value = "0";
    }
  }

  // ─── RETRY IMAGE LOAD ─────────────────────────────────────────────────────
  void retryImageLoad() {
    final current = userImage.value.split('?v=')[0];
    if (current.isNotEmpty) {
      userImage.value =
      "$current?v=${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  void logout() async {
    await StorageService.delete(key: 'user');
    await StorageService.delete(key: 'token');
    Get.offAllNamed('/login');
  }
}