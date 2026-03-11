import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);

  // 🟢 Fixed getImageUrl — handles all cases
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg";
    }

    String finalPath = path;

    // 🟢 Replace localhost/127.0.0.1 for Android emulator
    if (Platform.isAndroid) {
      finalPath = finalPath
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }

    // 🟢 Build full URL if relative path
    if (!finalPath.startsWith('http')) {
      finalPath = "http://10.0.2.2:8000/storage/$finalPath";
    }

    return finalPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back()),
        title: const Text('Edit Profile',
            style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // ─── AVATAR ───────────────────────────────────────────────
            Center(
              child: Obx(() {
                return GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: primaryColor.withOpacity(0.5),
                              width: 4),
                        ),
                        child: ClipOval(
                          child: _buildAvatarImage(),
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
                            border:
                            Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),

            _buildTextField(
                controller: controller.nameController,
                label: "Full Name",
                icon: Icons.person_outline),
            const SizedBox(height: 20),

            _buildTextField(
                controller: controller.emailController,
                label: "Email Address",
                icon: Icons.email_outlined,
                readOnly: true),

            const SizedBox(height: 50),

            // ─── SAVE BUTTON ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.updateProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text("Saving...",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                )
                    : const Text("Save Changes",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AVATAR IMAGE BUILDER ──────────────────────────────────────────────
  Widget _buildAvatarImage() {
    // 🟢 Show local picked image first
    if (controller.newProfileImgPath.value.isNotEmpty) {
      return Image.file(
        File(controller.newProfileImgPath.value),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    // 🟢 Show network image from server
    if (controller.currentImageUrl.value.isNotEmpty) {
      return Image.network(
        getImageUrl(controller.currentImageUrl.value),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        key: ValueKey(controller.currentImageUrl.value), // 🟢 force rebuild
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                  color: primaryColor, strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("Avatar load error: $error");
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[100],
            child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
          );
        },
      );
    }

    // 🟢 Default placeholder
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[100],
      child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
    );
  }

  // ─── TEXT FIELD ───────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(icon,
                  color: readOnly ? Colors.grey : primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}