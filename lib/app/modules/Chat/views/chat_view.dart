import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 1. Safely retrieve and cast arguments
    final dynamic args = Get.arguments;

    // Ensure types match exactly what the Controller expects (int and String)
    final int shopId = (args is Map && args['shopId'] != null)
        ? args['shopId'] as int
        : 0;

    final String shopToken = (args is Map && args['shopToken'] != null)
        ? args['shopToken'] as String
        : "";

    // Load messages when the view opens
    controller.loadMessages(shopId);

    return Scaffold(
      appBar: AppBar(
        title: Text("chat_with_shopkeeper".tr),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🟢 MESSAGE LIST
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                var m = controller.messages[index];
                // 🟢 Ensure alignment matches 'user' type
                bool isMe = m['sender_type'] == 'user';
                return _bubble(m, isMe);
              },
            )),
          ),

          // 🟢 UPLOADING INDICATOR
          Obx(() => controller.isUploading.value
              ? const LinearProgressIndicator(color: Colors.redAccent)
              : const SizedBox.shrink()),

          // 🟢 INPUT AREA (Passing the variables here)
          _inputArea(shopId, shopToken),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> m, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.redAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(15).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: m['image_url'] != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            controller.getImageUrl(m['image_url']),
            width: 200,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
          ),
        )
            : Text(
          m['message'] ?? "",
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  // 🟢 FIXED: Using the local 'id' and 'token' passed into the method
  Widget _inputArea(int id, String token) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.grey),
            onPressed: () => controller.uploadImage(id, token),
          ),
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: InputDecoration(
                hintText: "type_message".tr,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.redAccent),
            // 🟢 FIXED: Using the parameters passed to this helper
            onPressed: () => controller.sendTextMessage(id, token),
          ),
        ],
      ),
    );
  }
}