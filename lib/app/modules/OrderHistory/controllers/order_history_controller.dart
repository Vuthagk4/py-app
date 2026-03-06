import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/providers/api_provider.dart';
import '../../Cart/controllers/cart_controller.dart'; // 🟢 Import your CartController
import '../../../data/models/product.model.dart'; // 🟢 Import your Product model

class OrderHistoryController extends GetxController {
  final _provider = Get.find<APIProvider>();
  var orders = <dynamic>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final response = await _provider.getOrders();
      if (response.statusCode == 200) {
        orders.assignAll(response.data);
      }
    } catch (e) {
      print("Error fetching order history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🟢 RE-ORDER FUNCTION
  Future<void> reOrder(Map<String, dynamic> order) async {
    try {
      final CartController cartController = Get.find<CartController>();
      List<dynamic> pastItems = order['items'] ?? [];

      if (pastItems.isEmpty) {
        Get.snackbar("Notice", "No items found in this order.");
        return;
      }

      for (var item in pastItems) {
        final product = Products.fromJson(item['product']);
        int quantity = item['quantity'] ?? 1;
        for (int i = 0; i < quantity; i++) {
          cartController.addToCart(product);
        }
      }

      Get.snackbar("Success", "Items added back to cart!",
          backgroundColor:  Color(0xFF2563EB), colorText: Colors.white);
      Get.toNamed('/cart');
    } catch (e) {
      Get.snackbar("Error", "Could not restore items.");
    }
  }

  Future<void> generateInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("PHNOM PENH STORE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Invoice ID: #${order['id']}"),
              pw.Text("Date: ${order['created_at']?.toString().substring(0, 10) ?? 'N/A'}"),
              pw.Divider(),
              pw.Text("Delivery To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(order['delivery_address'] ?? "No Address Provided"),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Description', 'Amount'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                data: [
                  ['Order Total Amount', "\$${order['total_amount']}"],
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text("Thank you for your purchase!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${order['id']}.pdf',
    );
  }
}