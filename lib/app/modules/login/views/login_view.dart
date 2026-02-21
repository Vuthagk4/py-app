import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Brand Color (Same as HomeView)
    const primaryColor = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.height, // Full screen height
          child: Stack(
            children: [
              // --- 1. RED CURVED BACKGROUND ---
              ClipPath(
                clipper: _HeaderClipper(),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: primaryColor,
                  padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Sign in to continue shopping",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. THE FORM CARD ---
              Positioned(
                top: 200,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
                          ),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                                "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg"),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Email Field
                        _buildCustomField(
                          controller: emailController,
                          hint: "Email Address",
                          icon: Icons.email_outlined,
                          color: primaryColor,
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        _buildCustomField(
                          controller: passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          color: primaryColor,
                        ),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value ? null : () {
                              if (_formKey.currentState!.validate()) {
                                controller.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim()
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 3. REGISTER LINK (Bottom) ---
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // PRESERVED LOGIC: Wait for Register screen result
                        var result = await Get.toNamed('/register');

                        // If data comes back, fill the controllers
                        if (result != null && result is Map) {
                          if (result['email'] != null) emailController.text = result['email'];
                          if (result['password'] != null) passwordController.text = result['password'];

                          Get.snackbar(
                            "Success",
                            "Account created! Please login.",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Text(
                        "Register Now",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CUSTOM WIDGETS ---

  Widget _buildCustomField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) {
          if (value == null || value.isEmpty) return "Required";
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}

// --- CURVE CLIPPER ---
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}