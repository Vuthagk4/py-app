import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';

class NotificationController extends GetxController {
  final _provider = Get.find<APIProvider>();

  var notifications = <dynamic>[].obs;
  var filteredNotifications = <dynamic>[].obs;
  var isLoading = true.obs;

  int get unreadCount => notifications.where((n) => n['read_at'] == null).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      if (notifications.isEmpty) isLoading.value = true;
      final response = await _provider.getNotifications();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        notifications.assignAll(data);
        filteredNotifications.assignAll(data);
      }
    } catch (e) {
      print("⛔ Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🟢 FIXED: Calling the specific provider method
  Future<void> deleteAllNotifications() async {
    if (notifications.isEmpty) return;

    try {
      final response = await _provider.clearAllNotifications();
      if (response.statusCode == 200) {
        // Clear local lists instantly
        notifications.clear();
        filteredNotifications.clear();

        if (Get.isDialogOpen!) Get.back(); // 🟢 Safely close dialog

        Get.snackbar(
          "Success",
          "All notifications cleared",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("⛔ Clear All Error: $e");
    }
  }

  Future<void> markAsReadById(String id) async {
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1 && notifications[index]['read_at'] != null) return;
    try {
      final response = await _provider.markAsRead(id);
      if (response.statusCode == 200) {
        _updateLocalReadStatus(id);
      }
    } catch (e) {
      print("⛔ Mark Read Error: $e");
    }
  }

  void _updateLocalReadStatus(String id) {
    final now = DateTime.now().toIso8601String();
    for (var list in [notifications, filteredNotifications]) {
      int index = list.indexWhere((n) => n['id'] == id);
      if (index != -1) list[index]['read_at'] = now;
    }
    notifications.refresh();
    filteredNotifications.refresh();
  }

  void filterNotifications(String query) {
    if (query.isEmpty) {
      filteredNotifications.assignAll(notifications);
    } else {
      filteredNotifications.assignAll(notifications.where((notif) {
        final data = notif['data'] ?? {};
        final title = data['title']?.toString().toLowerCase() ?? "";
        final body = data['body']?.toString().toLowerCase() ?? "";
        return title.contains(query.toLowerCase()) || body.contains(query.toLowerCase());
      }).toList());
    }
  }

  Future<void> deleteNotificationById(String id) async {
    try {
      final response = await _provider.deleteNotification(id);
      if (response.statusCode == 200) {
        notifications.removeWhere((n) => n['id'] == id);
        filteredNotifications.removeWhere((n) => n['id'] == id);
      }
    } catch (e) {
      fetchNotifications();
    }
  }

  Future<void> markAllRead() async {
    if (notifications.isEmpty) return;
    try {
      final response = await _provider.markAllRead();
      if (response.statusCode == 200) {
        for (var n in notifications) {
          if (n['read_at'] == null) n['read_at'] = DateTime.now().toIso8601String();
        }
        notifications.refresh();
        filteredNotifications.refresh();
      }
    } catch (e) {
      print(e);
    }
  }
}