import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Ambient Glow Background ──
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF5252).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF5252).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // ── Logo / Brand Mark ──
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Headline ──
                  const Text(
                    "Welcome\nback.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign in to your account",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ── Form ──
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        _ModernField(
                          controller: controller.emailController,
                          hint: "Email address",
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _ModernField(
                          controller: controller.passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                            ),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: Color(0xFFFF5252),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Sign In Button
                        Obx(() => GestureDetector(
                          onTap: controller.isLoading.value
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              controller.login(
                                controller.emailController.text.trim(),
                                controller.passwordController.text.trim(),
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              color: controller.isLoading.value
                                  ? const Color(0xFFFF5252).withOpacity(0.6)
                                  : const Color(0xFFFF5252),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: controller.isLoading.value
                                  ? []
                                  : [
                                BoxShadow(
                                  color: const Color(0xFFFF5252)
                                      .withOpacity(0.45),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        )),

                        const SizedBox(height: 32),

                        // ── Divider ──
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "or continue with",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Social Buttons ──
                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                label: "Google",
                                icon: Icons.g_mobiledata_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _SocialButton(
                                label: "Facebook",
                                icon: Icons.facebook_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ── Register Link ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?  ",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var result = await Get.toNamed('/register');
                                if (result != null && result is Map) {
                                  if (result['email'] != null)
                                    controller.emailController.text =
                                    result['email'];
                                  if (result['password'] != null)
                                    controller.passwordController.text =
                                    result['password'];
                                  Get.snackbar(
                                    "Success",
                                    "Account created! Please login.",
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  color: Color(0xFFFF5252),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modern Input Field ──
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
                ? const Color(0xFFFF5252).withOpacity(0.6)
                : Colors.white.withOpacity(0.07),
            width: 1.5,
          ),
          boxShadow: _focused
              ? [
            BoxShadow(
              color: const Color(0xFFFF5252).withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 0,
            )
          ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          validator: (v) =>
          (v == null || v.isEmpty) ? "This field is required" : null,
          decoration: InputDecoration(
            prefixIcon: Icon(
              widget.icon,
              color: _focused
                  ? const Color(0xFFFF5252)
                  : Colors.white.withOpacity(0.3),
              size: 22,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
                : null,
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 8,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social Button ──
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF161620),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}