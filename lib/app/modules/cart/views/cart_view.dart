import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khqrcode/khqrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:confetti/confetti.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      extendBody: true,
      appBar: AppBar(
        title: const Text('Shopping Bag',
            style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text("${controller.cartItems.length} Items",
                  style: TextStyle(color: Colors.blueGrey[400], fontWeight: FontWeight.w600)),
            ),
          ))
        ],
      ),
      bottomNavigationBar: _buildModernGlassCheckout(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProductList(),
                _buildLocationPreviewCard(),
                const SizedBox(height: 140),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: controller.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.blue, Colors.green, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGlassCheckout() {
    return Obx(() {
      if (controller.cartItems.isEmpty) return const SizedBox.shrink();

      return ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Balance",
                          style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                      Text("\$${controller.totalCartPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showBakongPaymentSheet(Get.context!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                    elevation: 10,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Checkout Now",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.cartItems.isEmpty) return _buildEmptyState();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: controller.cartItems.length,
        itemBuilder: (context, index) {
          final item = controller.cartItems[index];
          return _buildModernCartItem(item, index);
        },
      );
    });
  }

  Widget _buildLocationPreviewCard() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: ListTile(
        onTap: () => controller.openMapPicker(),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
          child: const Icon(Icons.map_outlined, color: Color(0xFF2563EB)),
        ),
        title: const Text("Delivery Location", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          controller.pickedLocation.value == null
              ? "Tap to select on map"
              : "Location Pin Set ✅",
          style: TextStyle(color: controller.pickedLocation.value == null ? Colors.red : Colors.green),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    ));
  }

  Widget _buildModernCartItem(var item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 95, height: 95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: NetworkImage(item.product.image ?? "https://via.placeholder.com/150"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name ?? "Product",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text("\$${item.product.price}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildNeumorphicQty(Icons.remove, () => controller.decreaseQuantity(index)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text("${item.quantity}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _buildNeumorphicQty(Icons.add, () => controller.increaseQuantity(index)),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeItem(index),
            icon: CircleAvatar(
                backgroundColor: Colors.red[50],
                child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20)),
          ),
        ],
      ),
    );
  }

  void _showBakongPaymentSheet(BuildContext context) {
    final bakongKhqr = BakongKHQR();
    final individualInfo = IndividualInfo(
      bakongAccountId: 'your_id@acleda',
      merchantName: 'Phnom Penh Store',
      merchantCity: 'Phnom Penh',
      amount: controller.totalCartPrice,
      currency: KHQRDataConst.currency['usd']!,
    );

    final result = bakongKhqr.generateIndividual(individualInfo);
    final String khqrString = result.data?.qr ?? "";

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              const Text("Secure Payment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text("Scan KHQR to pay", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 30),
              _buildPremiumQR(khqrString),
              const SizedBox(height: 30),
              _buildStepIndicator(),
              const SizedBox(height: 20),
              Obx(() => _buildSlipPreviewSection()),
              const SizedBox(height: 20),
              _buildPremiumCheckoutButton(),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPremiumQR(String data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 180.0,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF0F172A)),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stepAction(
            icon: Icons.account_balance_wallet_rounded,
            label: "Open Bank",
            onTap: () => controller.openBankingApp(),
            isActive: controller.selectedSlip.value == null
        ),
        _stepLine(),
        _stepAction(
            icon: Icons.camera_alt_rounded,
            label: "Capture",
            onTap: () => controller.capturePaymentSlip(),
            isActive: controller.selectedSlip.value != null
        ),
        _stepLine(),
        _stepAction(
            icon: Icons.cloud_upload_rounded,
            label: "Upload",
            onTap: null,
            isActive: controller.isLoading.value
        ),
      ],
    ));
  }

  Widget _stepAction({required IconData icon, required String label, VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: isActive ? Colors.white : Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF2563EB) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _stepLine() => Container(width: 30, height: 2, color: const Color(0xFFF1F5F9));

  Widget _buildSlipPreviewSection() {
    if (controller.selectedSlip.value == null) return const SizedBox.shrink();
    return ListTile(
      leading: Image.file(File(controller.selectedSlip.value!.path), width: 50, height: 50, fit: BoxFit.cover),
      title: const Text("Slip Attached", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => controller.selectedSlip.value = null
      ),
    );
  }

  Widget _buildPremiumCheckoutButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : (controller.selectedSlip.value == null
            ? () => controller.pickPaymentSlip()
            : () => controller.processPaymentSuccess()),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.selectedSlip.value == null ? const Color(0xFF0F172A) : Colors.green[600],
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: controller.isLoading.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
            controller.selectedSlip.value == null ? "I have Paid (Upload Slip)" : "Complete Purchase",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
        ),
      ),
    ));
  }

  Widget _buildNeumorphicQty(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Your bag is empty",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}