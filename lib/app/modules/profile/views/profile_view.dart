import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../services/localization_service.dart';
import '../../Map_Shipping/MapPickerView.dart';
import '../../OrderHistory/controllers/order_history_controller.dart';
import '../controllers/profile_controller.dart';
import '../../OrderHistory/views/order_history_view.dart';
import '../../help_support/views/help_support_view.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);
  final Color accentOrange = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    // 🟢 Refresh stats whenever the view is built
    controller.fetchOrderStats();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 🟢 CURVED HEADER SECTION
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, accentOrange.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderButton(Icons.arrow_back_ios_new, () => Get.back()),
                          Text("profile".tr,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          _buildHeaderButton(Icons.notifications_none_rounded, () {}),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(bottom: -60, child: _buildFloatingAvatar()),
              ],
            ),

            const SizedBox(height: 70),

            // 🟢 USER INFO
            Obx(() => Column(
              children: [
                Text(controller.userName.value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(controller.userEmail.value,
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ],
            )),

            const SizedBox(height: 25),
            _buildModernStats(context),

            // 🟢 ACCOUNT SECTION
            _buildSectionCard(context, "account_section".tr, [
              _buildModernMenuItem(context, Icons.person_outline_rounded, "personal_data".tr,
                  onTap: () async {
                    final result = await Get.toNamed('/edit-profile');
                    if (result == true) controller.getUserData();
                  }),

              _buildModernMenuItem(context, Icons.map_outlined, "shipping_address".tr,
                  onTap: () async {
                    LocationPermission permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                      await Get.to(() => const MapPickerView());
                    }
                  }),
              _buildSectionCard(context, "activity_support".tr, [
                // 1. Order History
                _buildModernMenuItem(context, Icons.history_rounded, "order_history".tr,
                    onTap: () => Get.to(() {
                      Get.put(OrderHistoryController());
                      return const OrderHistoryView();
                    })),

                // 🟢 2. ADD THIS: Chat with Shopkeeper
                _buildModernMenuItem(
                  context,
                  Icons.chat_bubble_outline_rounded,
                  "chat_with_shopkeeper".tr,
                  onTap: () => Get.toNamed('/chat', arguments: {
                    'shopId': 1, // Default Admin ID for your CentOS 9 backend
                    'shopToken': '', // Will be filled via FCM logic
                  }),
                ),

                // 3. Help Center
                _buildModernMenuItem(context, Icons.help_outline_rounded, "help_center".tr,
                    onTap: () => Get.to(() => const HelpSupportView())),
              ]),

              _buildModernMenuItem(context, Icons.language_rounded, "language".tr,
                  onTap: () => _showLanguageDialog(context)),

              Obx(() => _buildModernToggleItem(context, Icons.dark_mode_outlined, "dark_mode".tr,
                  controller.isDarkMode.value, (val) => controller.toggleDarkMode(val))),
            ]),



            const SizedBox(height: 20),
            _buildLogoutButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- HELPER BUILDERS ---

  void _showLanguageDialog(BuildContext context) {
    Get.defaultDialog(
      title: "language".tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: context.theme.cardColor,
      radius: 20,
      content: Column(
        children: [
          _buildLanguageOption("English", "English"),
          _buildLanguageOption("ភាសាខ្មែរ", "Khmer"),
          _buildLanguageOption("中文", "Chinese"),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.check_circle_outline, size: 18, color: Colors.grey),
      onTap: () {
        LocalizationService.changeLoc(value);
        Get.back();
      },
    );
  }

  Widget _buildModernStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          _buildStatCard(context, controller.orderCount.value, "orders".tr, Icons.shopping_bag_outlined,
              onTap: () => Get.to(() {
                Get.put(OrderHistoryController());
                return const OrderHistoryView();
              })),
          const SizedBox(width: 15),
          _buildStatCard(context, "0", "wishlist".tr, Icons.favorite_border),
          const SizedBox(width: 15),
          _buildStatCard(context, "0", "points".tr, Icons.stars_rounded),
        ],
      )),
    );
  }

  Widget _buildStatCard(BuildContext context, String val, String label, IconData icon, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              const SizedBox(height: 5),
              Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: context.theme.cardColor, borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildModernMenuItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildModernToggleItem(BuildContext context, IconData icon, String title, bool val, Function(bool) onType) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(value: val, onChanged: onType, activeColor: primaryColor),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => controller.logout(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200], foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text("sign_out".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildFloatingAvatar() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[100],
        child: ClipOval(
          child: Image.network(
            controller.getImageUrl(controller.userImage.value),
            fit: BoxFit.cover, width: 120, height: 120,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 60, color: Colors.grey[400]),
          ),
        ),
      ),
    ));
  }
}