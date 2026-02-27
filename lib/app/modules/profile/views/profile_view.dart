import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../OrderHistory/controllers/order_history_controller.dart';
import '../controllers/profile_controller.dart';
import '../../OrderHistory/views/order_history_view.dart';
import '../../help_support/views/help_support_view.dart';
import '../../privacy_policy/views/privacy_policy_view.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🟢 Uses the global theme context (Light or Dark based on toggle)
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // 1. Sticky Header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("My Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: true,
              background: Container(color: primaryColor),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // 2. Hero Card
                _buildHeroCard(context),

                // 3. Horizontal Stats Dashboard
                _buildOrderDashboard(context),

                // 4. Grouped Menus Section
                _buildMenuSection(context, "Account Settings", [
                  _buildNewMenuItem(context, Icons.person_outline, "Personal Details", "Name & Photo",
                      onTap: () async {
                        final result = await Get.toNamed('/edit-profile');
                        if (result == true) controller.getUserData();
                      }),

                  // 🟢 DYNAMIC DARK MODE TOGGLE
                  Obx(() => _buildToggleMenuItem(
                      context,
                      Icons.dark_mode_outlined,
                      "Dark Mode",
                      "Switch visual theme",
                      controller.isDarkMode.value,
                          (val) => controller.toggleDarkMode(val)
                  )),

                  _buildNewMenuItem(context, Icons.location_on_outlined, "Shipping Address", "Your saved locations", onTap: () {}),
                ]),
                _buildMenuSection(context, "Activity", [
                  _buildNewMenuItem(
                    context,
                    Icons.chat_bubble_outline_rounded,
                    "My Feedback",
                    "View your shared experiences",
                    onTap: () => Get.toNamed('/my-feedback'),
                  ),
                  _buildNewMenuItem(context, Icons.favorite_border, "Wishlist", "Items you've saved", onTap: () {}),
                ]),

                _buildMenuSection(context, "Support", [
                  _buildNewMenuItem(context, Icons.help_outline, "Help & Support", "FAQs & Contact",
                      onTap: () => Get.to(() => const HelpSupportView())),
                  _buildNewMenuItem(context, Icons.privacy_tip_outlined, "Privacy Policy", "Terms and conditions",
                      onTap: () => Get.to(() => const PrivacyPolicyView())),
                ]),

                const SizedBox(height: 30),
                _buildLogoutButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN COMPONENT BUILDERS ---

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.cardColor, // Adapts to Dark/Light mode
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10)
          )
        ],
      ),
      child: Obx(() => Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(controller.getImageUrl(controller.userImage.value)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.userName.value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(controller.userEmail.value,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildOrderDashboard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          _buildStatBox(context, "Orders", controller.orderCount.value, Icons.shopping_bag_outlined, // Change this line in your _buildStatBox call:
                  () => Get.to(() {
                // 🟢 Manually initialize the controller
                Get.put(OrderHistoryController());
                return const OrderHistoryView();
              })),
          const SizedBox(width: 15),
          _buildStatBox(context, "Wishlist", "0", Icons.favorite_border, () {}),
          const SizedBox(width: 15),
          _buildStatBox(context, "Coupons", "0", Icons.local_offer_outlined, () {}),
        ],
      )),
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String val, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 0, 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(25)
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildNewMenuItem(BuildContext context, IconData icon, String title, String sub, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
    );
  }

  Widget _buildToggleMenuItem(BuildContext context, IconData icon, String title, String sub, bool val, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: val,
        onChanged: onChanged,
        activeColor: primaryColor,
        activeTrackColor: primaryColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () => controller.logout(),
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          foregroundColor: primaryColor,
        ),
        child: const Text("LOG OUT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }
}