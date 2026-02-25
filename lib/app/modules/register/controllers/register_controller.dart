import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:faker/faker.dart';
import '../../../data/providers/api_provider.dart';

class RegisterController extends GetxController {
  final _provider = Get.find<APIProvider>();
  final _imagePicker = ImagePicker();
  final faker = Faker();

  // Text Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // Reactive Variables (Fixes the "not found" errors)
  var profileImgPath = ''.obs;
  var isLoading = false.obs;
  File? profileImg;

  @override
  void onInit() {
    generateUser();
    super.onInit();
  }

  void pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      profileImg = File(file.path);
      profileImgPath.value = file.path; // Updates the UI instantly
    }
  }

  void generateUser() {
    nameController.text = faker.person.name();
    emailController.text = faker.internet.email();
    passController.text = "123123123";
  }

  // Method signature matches the View's named parameters
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await _provider.register(
          name: name,
          email: email,
          password: password,
          image: profileImg
      );

      // 🟢 FIX 1: Check for 201 (Created) AND 200 (OK)
      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.dialog(
          AlertDialog(
            title: const Text('Success'),
            content: const Text('Registration successful'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close Dialog

                  // 🟢 FIX 2: Send data back to the login screen
                  Get.back(result: {'email': email, 'password': password});
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // 🟢 FIX 3: Show Laravel validation errors (e.g., "Email already taken")
        Get.defaultDialog(
            title: "Registration Failed",
            middleText: response.data['message'] ?? "Please check your details."
        );
      }
    } catch (e) {
      Get.defaultDialog(title: "Error", content: Text(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }
}