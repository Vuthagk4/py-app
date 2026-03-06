import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Map_Shipping/MapPickerView.dart';
import '../../OrderHistory/controllers/order_history_controller.dart';
import '../controllers/profile_controller.dart';
import '../../OrderHistory/views/order_history_view.dart';
import '../../help_support/views/help_support_view.dart';
import '../../privacy_policy/views/privacy_policy_view.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);
  final Color accentOrange = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
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
                          const Text("Profile",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
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
            _buildSectionCard(context, "Account", [
              _buildModernMenuItem(context, Icons.person_outline_rounded, "Personal Data",
                  onTap: () async {
                    final result = await Get.toNamed('/edit-profile');
                    if (result == true) controller.getUserData();
                  }),

              // 🟢 MAP PICKER TRIGGER
              _buildModernMenuItem(context, Icons.map_outlined, "Shipping Addresses",
                  onTap: () async {
                    LocationPermission permission = await Geolocator.requestPermission(); //
                    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                      final LatLng? selectedLocation = await Get.to(() => const MapPickerView());
                      if (selectedLocation != null) {
                        Get.snackbar("Location Saved", "Lat: ${selectedLocation.latitude}, Lng: ${selectedLocation.longitude}",
                            backgroundColor: Colors.green, colorText: Colors.white);
                      }
                    }
                  }),

              Obx(() => _buildModernToggleItem(context, Icons.dark_mode_outlined, "Dark Mode",
                  controller.isDarkMode.value, (val) => controller.toggleDarkMode(val))),
            ]),

            _buildSectionCard(context, "Activity & Support", [
              _buildModernMenuItem(context, Icons.history_rounded, "Order History",
                  onTap: () => Get.to(() {
                    Get.put(OrderHistoryController());
                    return const OrderHistoryView();
                  })),
              _buildModernMenuItem(context, Icons.help_outline_rounded, "Help Center",
                  onTap: () => Get.to(() => const HelpSupportView())),
            ]),

            const SizedBox(height: 20),
            _buildLogoutButton(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT BUILDERS ---
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

  Widget _buildModernStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: [
          _buildStatCard(context, controller.orderCount.value, "Orders", Icons.shopping_bag_outlined,
              onTap: () => Get.to(() {
                Get.put(OrderHistoryController());
                return const OrderHistoryView();
              })),
          const SizedBox(width: 15),
          _buildStatCard(context, "0", "Wishlist", Icons.favorite_border),
          const SizedBox(width: 15),
          _buildStatCard(context, "0", "Points", Icons.stars_rounded),
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
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.06), borderRadius: BorderRadius.circular(20)),
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
          decoration: BoxDecoration(color: context.theme.cardColor, borderRadius: BorderRadius.circular(25)),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildModernMenuItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  Widget _buildModernToggleItem(BuildContext context, IconData icon, String title, bool val, Function(bool) onType) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
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
        child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}