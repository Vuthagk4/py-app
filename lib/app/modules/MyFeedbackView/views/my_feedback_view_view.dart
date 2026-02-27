import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_feedback_view_controller.dart';

class MyFeedbackView extends GetView<MyFeedbackController> {
  const MyFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("My Feedback", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)));
          }
          if (controller.feedbackList.isEmpty) {
            return const Center(child: Text("No feedback found", style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.feedbackList.length,
            itemBuilder: (context, index) {
              final item = controller.feedbackList[index];
              return _buildCard(item);
            },
          );
        }),
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['product']?['name'] ?? "Item", style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildStars(item['rating'] ?? 5),
            ],
          ),
          const SizedBox(height: 8),
          Text("${item['comment']}", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Text("${item['created_at']}".substring(0, 10), style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.amber, size: 16
      )),
    );
  }
}