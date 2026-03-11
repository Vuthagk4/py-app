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

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 🟢 រចនាបែប Professional Dialog
        Get.dialog(
          barrierDismissible: false,
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:  Colors.black, // ពណ៌ Dark Blue ងងឹត
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1), // បន្ថែមគែមស្ដើងៗដើម្បីឱ្យលេចចេញពី Background
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🟢 Icon Success ជាមួយនឹងចលនា
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.greenAccent,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "ចុះឈ្មោះជោគជ័យ!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "គណនីរបស់អ្នកត្រូវបានបង្កើតរួចរាល់។\nសូមរីករាយជាមួយការទិញទំនិញ!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🟢 ប៊ូតុងរចនាបែបទំនើប
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // បិទ Dialog
                        Get.back(result: {'email': email, 'password': password});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber, // ឬពណ៌ Primary របស់អ្នក
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "ទៅកាន់ទំព័រ Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // បង្ហាញ Error បើចុះឈ្មោះមិនបាន
        Get.snackbar(
          "ចុះឈ្មោះមិនជោគជ័យ",
          response.data['message'] ?? "សូមពិនិត្យទិន្នន័យម្តងទៀត",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("កំហុស", "ការតភ្ជាប់មានបញ្ហា");
    } finally {
      isLoading.value = false;
    }
  }
}