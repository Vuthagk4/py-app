import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg";
    }
    if (path.startsWith("http") && Platform.isAndroid) {
      return path.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Center(
              child: Obx(() {
                ImageProvider imageProvider;
                // If user just picked a local image, show that.
                // Otherwise, load the Network Image (which now has the cache-busting timestamp!)
                if (controller.newProfileImgPath.value.isNotEmpty) {
                  imageProvider = FileImage(File(controller.newProfileImgPath.value));
                } else {
                  imageProvider = NetworkImage(getImageUrl(controller.currentImageUrl.value));
                }

                return GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withOpacity(0.5), width: 4),
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            _buildTextField(controller: controller.nameController, label: "Full Name", icon: Icons.person_outline),
            const SizedBox(height: 20),

            _buildTextField(controller: controller.emailController, label: "Email Address", icon: Icons.email_outlined, readOnly: true),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.updateProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: readOnly ? Colors.grey : primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}