import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago; // 🟢 Required
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
        actions: [
          // 🟢 Clear All Button
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () => _showClearAllDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.black),
            onPressed: () => controller.markAllRead(),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)));
              }
              final list = controller.filteredNotifications;
              if (list.isEmpty) return _buildEmptyState();

              return RefreshIndicator(
                color: const Color(0xFFFF5252),
                onRefresh: () => controller.fetchNotifications(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, index) => _buildNotificationItem(list[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(dynamic notif) {
    final Map<String, dynamic> msgData = notif['data'] ?? {};
    final bool isRead = notif['read_at'] != null;

    // 🟢 Time Ago Formatting
    final DateTime createdAt = DateTime.parse(notif['created_at'].toString());
    final String timeText = timeago.format(createdAt);

    return Dismissible(
      key: Key(notif['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotificationById(notif['id'].toString()),
      child: InkWell(
        onTap: () => controller.markAsReadById(notif['id'].toString()),
        child: Container(
          color: isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isRead ? Colors.grey[200] : Colors.red[50],
                child: Icon(Icons.notifications, color: isRead ? Colors.grey : Colors.red),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msgData['title'] ?? "", style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                    Text(msgData['body'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(timeText, style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              if (!isRead) const CircleAvatar(radius: 4, backgroundColor: Colors.yellow),
            ],
          ),
        ),
      ),
    );
  }

  // 🟢 Confirmation Dialog Logic
  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Clear All?"),
        content: const Text("This will permanently delete all your notifications."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () => controller.deleteAllNotifications(),
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        onChanged: (value) => controller.filterNotifications(value),
        decoration: InputDecoration(
          hintText: "Search...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const Text("No notifications yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}