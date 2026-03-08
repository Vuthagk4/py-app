import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio; // 🟢 Standardized alias
import 'package:py_app/app/data/providers/api_provider.dart';
import '../../../utils/helper/fcm_helper.dart';

class ChatController extends GetxController {
  Timer? _timer;
  @override
  void onInit() {
    super.onInit();
    // 🟢 Start polling every 3 seconds to fetch new messages
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final dynamic args = Get.arguments ?? {};
      if (args['shopId'] != null) {
        loadMessages(args['shopId']);
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel(); // 🟢 Crucial: Stop polling when leaving the chat
    super.onClose();
  }
  final _provider = Get.find<APIProvider>();
  var messages = <Map<String, dynamic>>[].obs;
  var isUploading = false.obs;
  final TextEditingController textController = TextEditingController();

  // 🟢 Added ScrollController for auto-scroll
  final ScrollController scrollController = ScrollController();



  String getImageUrl(String? path) => _provider.getImageUrl(path);

  // 🟢 Helper to move to latest message
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> uploadImage(int id, String token) async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    isUploading.value = true;

    // 🟢 Using the 'dio' alias correctly
    dio.FormData data = dio.FormData.fromMap({
      'shopkeeper_id': id,
      'image': await dio.MultipartFile.fromFile(image.path),
      'message': 'Sent a photo 📷',
    });

    try {
      await _provider.sendChatMessage(data);
      await FcmHelper.sendNotification(
          deviceToken: token,
          room: {'id': id},
          message: "📷 Image",
          isTextSend: false
      );
      loadMessages(id);
    } catch (e) {
      Get.snackbar("Error", "Could not upload image");
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> sendTextMessage(int id, String token) async {
    if (textController.text.trim().isEmpty) return;
    String content = textController.text.trim();

    dio.FormData data = dio.FormData.fromMap({
      'shopkeeper_id': id,
      'message': content,
    });

    try {
      textController.clear(); // Clear UI immediately for a better feel
      final response = await _provider.sendChatMessage(data);

      if (response.statusCode == 200) {
        // 🟢 CRITICAL: Reload the messages so they appear in the UI
        loadMessages(id);
      }
    } catch (e) {
      Get.snackbar("Error", "Message failed to send. Check CentOS server logs.");
    }
  }
  void loadMessages(int id) async {
    // 🟢 If 'id' is 0 because of an error above, this will return an empty list
    final response = await _provider.getChatMessages(id);
    if (response.statusCode == 200) {
      messages.assignAll(List<Map<String, dynamic>>.from(response.data));
      _scrollToBottom();
    }
  }
}