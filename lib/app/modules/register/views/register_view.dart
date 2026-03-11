import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  RegisterView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          Positioned(
            top: -100, left: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFF5252).withValues(alpha: 0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFF5252).withValues(alpha: 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161620),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: Obx(() => GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Stack(
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF5252).withValues(alpha: 0.8),
                                    const Color(0xFFFF5252).withValues(alpha: 0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: CircleAvatar(
                                  radius: 47,
                                  backgroundColor: const Color(0xFF161620),
                                  backgroundImage: controller.profileImgPath.value.isNotEmpty
                                      ? FileImage(File(controller.profileImgPath.value))
                                      : const NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                                  ) as ImageProvider,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2, right: 2,
                              child: Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5252),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF0A0A0F), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5252).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        "Tap to upload photo",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      "Create\naccount.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fill in your details to get started",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 15),
                    ),

                    const SizedBox(height: 40),

                    _ModernField(
                      controller: controller.nameController,
                      hint: "Full name",
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 14),
                    _ModernField(
                      controller: controller.emailController,
                      hint: "Email address",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _ModernField(
                      controller: controller.passController,
                      hint: "Password",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),

                    const SizedBox(height: 36),

                    Obx(() => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          controller.register(
                            name: controller.nameController.text,
                            email: controller.emailController.text,
                            password: controller.passController.text,
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          color: controller.isLoading.value
                              ? const Color(0xFFFF5252).withValues(alpha: 0.6)
                              : const Color(0xFFFF5252),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: controller.isLoading.value
                              ? []
                              : [
                            BoxShadow(
                              color: const Color(0xFFFF5252).withValues(alpha: 0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                              : const Text(
                            "Create Account",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3),
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 30),

                    Center(
                      child: Text(
                        "By registering, you agree to our Terms & Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?  ",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                                color: Color(0xFFFF5252),
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const _ModernField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_ModernField> createState() => _ModernFieldState();
}

class _ModernFieldState extends State<_ModernField> {
  bool _obscure = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF161620),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused
                ? const Color(0xFFFF5252).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.07),
            width: 1.5,
          ),
          boxShadow: _focused
              ? [BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.08),
              blurRadius: 16)]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          validator: (v) =>
          (v == null || v.isEmpty) ? "This field is required" : null,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon,
                color: _focused
                    ? const Color(0xFFFF5252)
                    : Colors.white.withValues(alpha: 0.3),
                size: 22),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
                : null,
            hintText: widget.hint,
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.25), fontSize: 16),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          ),
        ),
      ),
    );
  }
}