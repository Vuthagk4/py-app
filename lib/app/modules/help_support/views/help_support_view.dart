import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  final Color primaryColor = const Color(0xFFFF5252);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Section
            const Text("Contact Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildContactTile(Icons.headset_mic_outlined, "Customer Service", "Available 24/7"),
                  const Divider(height: 1),
                  _buildContactTile(Icons.email_outlined, "Email Us", "support@example.com"),
                  const Divider(height: 1),
                  _buildContactTile(Icons.language, "Website", "www.example.com"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // FAQ Section
            const Text("Frequently Asked Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildFaqTile("How can I track my order?", "You can track your order by going to the 'Orders' section in your profile and tapping on the specific order to view its status."),
            _buildFaqTile("What is the return policy?", "We offer a 30-day return policy for unused items in their original packaging. Please contact support to initiate a return."),
            _buildFaqTile("How do I change my shipping address?", "You can update your shipping address in the 'Account Settings' section of your profile before placing an order."),
            _buildFaqTile("Are my payment details secure?", "Yes, we use industry-standard encryption to ensure your payment details are completely secure and private."),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent), // Removes the border lines when expanded
        child: ExpansionTile(
          iconColor: primaryColor,
          collapsedIconColor: Colors.grey,
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: TextStyle(color: Colors.grey[600], height: 1.5)),
            )
          ],
        ),
      ),
    );
  }
}