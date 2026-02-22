import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khqrcode/khqrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Price", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      "\$${controller.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF5252)),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: () => _showBakongPaymentSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Checkout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          ),
        );
      }),

      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
                const SizedBox(height: 20),
                const Text("Your cart is empty!", style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(15),
          itemCount: controller.cartItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final item = controller.cartItems[index];

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        item.product.image ?? "https://via.placeholder.com/150",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name ?? "Product Name",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$${item.product.price}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF5252)),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            _buildQtyButton(Icons.remove, () => controller.decreaseQuantity(index)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("${item.quantity}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            _buildQtyButton(Icons.add, () => controller.increaseQuantity(index)),
                          ],
                        )
                      ],
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => controller.removeItem(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showBakongPaymentSheet(BuildContext context) {
    // 🔴 FIX 1: Create an instance of BakongKHQR first
    final bakongKhqr = BakongKHQR();
    // 1. Generate the Real KHQR Data String
    final individualInfo = IndividualInfo(
      bakongAccountId: 'https://acledabank.com.kh/acleda?payment_data=qWY5B2SAUfIhLblxzOtfu5ckLzMHjaSki6Ru0bsOyNK+ylPBgZ0sHH6BeGUscKoEXkjHP7/LTEdCmtFBViZJS4jGSXDxI9tXgVk7lVimJUGxcvfQpwkZxxex74QSHRY+jTP1LwDIOqnQab24UZjkW8L1livcH4pX7mHLzNL7ldtQqaAlVkllSFpaUBvOzKC39LyIFQzyc+ojGh+d7o0XU3+Cu6z1SdQZca9X87LHhKg=&key=khqr', // TODO: Add your actual Bakong ID
      merchantName: 'My E-Commerce App',
      merchantCity: 'Phnom Penh',
      amount: controller.totalPrice,
      currency: KHQRDataConst.currency['usd']!, // <--- THIS IS REQUIRED
      accountInformation: '068433469', // Included to prevent strict validation errors
      acquiringBank: 'ACELEDA',       // Included to prevent strict validation errors
    );


    // 🔴 FIX 3: Call generate on your instance (bakongKhqr)
    final result = bakongKhqr.generateIndividual(individualInfo);

    // Safely extract the QR string
    final String khqrString = result.data?.qr ?? "";

    // 2. Show the UI
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text("KHQR Payment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Total: \$${controller.totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Real Scannable QR Code Generated Here!
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 15, spreadRadius: 5)],
              ),
              child: QrImageView(
                data: khqrString,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),
            const Text("Scan this QR code with any banking app\n(ABA, ACLEDA, Bakong, etc.)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.processPaymentSuccess(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text("Simulate Payment Success", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
}