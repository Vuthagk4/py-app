import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: primaryBlue));
        if (controller.orders.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order, primaryBlue);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(dynamic order, Color primaryColor) {
    final status = order['status']?.toString().toUpperCase() ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFFE2E8F0).withOpacity(0.4), blurRadius: 20)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order['id']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusTracker(status), // 🟢 New Progress Line
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoChip(Icons.calendar_today_rounded, order['created_at']?.toString().substring(0, 10) ?? "Recent"),
                const SizedBox(width: 10),
                _buildInfoChip(Icons.shopping_bag_rounded, "${order['items'] != null ? (order['items'] as List).length : 0} Items"),
              ],
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text("\$${order['total_amount']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
                  ],
                ),
                Row(
                  children: [
                    // 🟢 Re-order Button
                    _buildIconButton(icon: Icons.repeat_rounded, color: Colors.purple, onTap: () => controller.reOrder(order)),
                    const SizedBox(width: 8),
                    // 🟢 Invoice Button
                    _buildIconButton(icon: Icons.download_rounded, color: Colors.blueGrey, onTap: () => controller.generateInvoice(order)),
                    const SizedBox(width: 8),
                    // 🟢 Track Button
                    ElevatedButton(
                      onPressed: () => _openMap(order['latitude'], order['longitude']),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Track", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTracker(String status) {
    final List<String> steps = ['PENDING', 'PROCESSING', 'COMPLETED'];
    int currentIndex = steps.indexOf(status);
    return Row(
      children: List.generate(steps.length, (index) {
        bool isDone = index <= currentIndex;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(color: isDone ? const Color(0xFF2563EB) : Colors.grey[300], shape: BoxShape.circle),
                child: Icon(isDone ? Icons.check : Icons.circle, size: 10, color: Colors.white),
              ),
              if (index < steps.length - 1) Expanded(child: Container(height: 2, color: isDone ? const Color(0xFF2563EB) : Colors.grey[300])),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIconButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // Helper widgets (Badge, Chips, Empty State, OpenMap) remain as in your previous version...
  Widget _buildStatusBadge(String status) {
    Color color = status == 'COMPLETED' ? Colors.green : (status == 'CANCELLED' ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Row(children: [Icon(icon, size: 12), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10))]),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("No Orders Found"));

  Future<void> _openMap(dynamic lat, dynamic lng) async {
    if (lat == null || lng == null) return;
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}