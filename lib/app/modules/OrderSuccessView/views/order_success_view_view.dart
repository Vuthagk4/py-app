import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🟢 SUCCESS ANIMATION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
            ),

            const SizedBox(height: 30),

            const Text(
              "Order Placed Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your items are being prepared and will be sent to the shop owner for approval.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 50),

            // 🟢 ACTION BUTTONS
            // 🟢 ACTION BUTTONS
            ElevatedButton(
              // 🟢 Updated: Use the specific route name for your MainView
              onPressed: () => Get.offAllNamed('/main'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Premium Blue to match your CartView
                minimumSize: const Size(double.infinity, 60),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("CONTINUE SHOPPING",
                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () => Get.offNamed('/order-history'), // Go to History
              child: Text("VIEW ORDER DETAILS",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}