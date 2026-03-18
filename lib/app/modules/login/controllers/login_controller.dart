import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../services/storage_service.dart'; // Verify this path

class LoginController extends GetxController {
  final _provider = Get.find<APIProvider>();

  // 1. Add the missing observable
  var isLoading = false.obs;

  // 2. Keep these controllers here (and remove them from the View)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 3. Change to positional arguments (String email, String password)
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true; // Start loading

      final response = await _provider.login(email: email, password: password);

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await StorageService.write(key: 'token', value: token);

        Map<String, dynamic> user = response.data['user'];
        await StorageService.write(key: 'user', value: jsonEncode(user));

        Get.offAllNamed(Routes.MAIN);
      } else {
        Get.defaultDialog(
          title: "Error",
          middleText: "Failed to login",
        );
      }
    } catch (e) {
      Get.defaultDialog(title: "Error", middleText: e.toString());
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}