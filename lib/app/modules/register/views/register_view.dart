import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  RegisterView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --- IMAGE PICKER SECTION ---
                Obx(() => GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: controller.profileImgPath.value.isNotEmpty
                            ? FileImage(File(controller.profileImgPath.value))
                            : const NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png") as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),

                Text("Create Account", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                Text("Join us to get started", style: GoogleFonts.poppins(color: Colors.grey)),
                const SizedBox(height: 30),

                // --- FORM FIELDS ---
                _buildTextField(
                    controller: controller.nameController,
                    hint: "Full Name",
                    icon: Icons.person_outline),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: controller.emailController,
                    hint: "Email",
                    icon: Icons.email_outlined),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: controller.passController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true),
                const SizedBox(height: 30),

                // --- REGISTER BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () {
                      if (_formKey.currentState!.validate()) {
                        // FIXED: Pass named arguments only
                        controller.register(
                            name: controller.nameController.text,
                            email: controller.emailController.text,
                            password: controller.passController.text
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("REGISTER",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  )),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: GoogleFonts.poppins()),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text("Login", style: GoogleFonts.poppins(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        validator: (val) => val!.isEmpty ? "Enter $hint" : null,
      ),
    );
  }
}