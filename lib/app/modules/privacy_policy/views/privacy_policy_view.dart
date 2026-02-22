import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last updated: February 2026",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("1. Introduction"),
            _buildParagraph("Welcome to our e-commerce application. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our app and tell you about your privacy rights."),

            _buildSectionTitle("2. Data We Collect"),
            _buildParagraph("We may collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:"),
            _buildBulletPoint("Identity Data: Includes first name, last name, username or similar identifier."),
            _buildBulletPoint("Contact Data: Includes billing address, delivery address, email address and telephone numbers."),
            _buildBulletPoint("Financial Data: Includes bank account and payment card details."),
            _buildBulletPoint("Transaction Data: Includes details about payments to and from you and other details of products you have purchased from us."),
            const SizedBox(height: 10),

            _buildSectionTitle("3. How We Use Your Data"),
            _buildParagraph("We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:"),
            _buildBulletPoint("Where we need to perform the contract we are about to enter into or have entered into with you."),
            _buildBulletPoint("Where it is necessary for our legitimate interests (or those of a third party) and your interests and fundamental rights do not override those interests."),
            const SizedBox(height: 10),

            _buildSectionTitle("4. Data Security"),
            _buildParagraph("We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorised way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know."),

            _buildSectionTitle("5. Your Legal Rights"),
            _buildParagraph("Under certain circumstances, you have rights under data protection laws in relation to your personal data, including the right to request access, correction, erasure, restriction, transfer, to object to processing, to portability of data and (where the lawful ground of processing is consent) to withdraw consent."),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}