import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../OrderHistory/controllers/order_history_controller.dart';
import '../../OrderHistory/views/order_history_view.dart';
import '../../help_support/views/help_support_view.dart';
import '../../privacy_policy/views/privacy_policy_view.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);

  // Helper to handle localhost issues on Android Emulators
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
        title: const Text('My Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black),
              onPressed: () {}
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Profile Header Section ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              child: Obx(() => Column(
                children: [
                  GestureDetector(
                    onTap: () => controller.pickAndUploadAvatar(),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(getImageUrl(controller.userImage.value)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: controller.isUploading.value
                                ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(controller.userName.value,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(controller.userEmail.value,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              )),
            ),

            // --- Stats Card (Orders, Wishlist, Coupons) ---
            Container(
              transform: Matrix4.translationValues(0.0, -10.0, 0.0),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => const OrderHistoryView(), binding: BindingsBuilder(() {
                        Get.put(OrderHistoryController());
                      })),
                      // FIX: Pass as .value (which is an int) and let the method handle conversion
                      child: _buildStatItem(
                        Icons.shopping_bag_outlined,
                        "Orders",
                        controller.orderCount.value,
                      ),
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[200]),
                    _buildStatItem(Icons.favorite_border, "Wishlist", 0),
                    Container(height: 40, width: 1, color: Colors.grey[200]),
                    _buildStatItem(Icons.local_offer_outlined, "Coupons", 0),
                  ],
                )),
              ),
            ),

            // --- Menu Items ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  _buildMenuItem(Icons.person_outline, "Personal Details", onTap: () async {
                    final result = await Get.toNamed('/edit-profile');
                    if (result == true) controller.getUserData();
                  }),
                  _buildMenuItem(Icons.location_on_outlined, "Shipping Address", onTap: () {}),
                  _buildMenuItem(Icons.payment_outlined, "Payment Methods", onTap: () {}),
                  _buildMenuItem(Icons.notifications_outlined, "Notifications", onTap: () {}),

                  const SizedBox(height: 20),
                  const Text("General", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  _buildMenuItem(Icons.help_outline, "Help & Support", onTap: () => Get.to(() => const HelpSupportView())),
                  _buildMenuItem(Icons.privacy_tip_outlined, "Privacy Policy", onTap: () => Get.to(() => const PrivacyPolicyView())),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => controller.logout(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("Log Out", style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: 'value' is now dynamic so it accepts both Int and String
  Widget _buildStatItem(IconData icon, String label, dynamic value) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text("$value", // String interpolation handles the conversion
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}