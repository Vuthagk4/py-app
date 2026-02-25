import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart'; // 1. Added url_launcher
import 'package:py_app/app/modules/cart/controllers/cart_controller.dart';

import '../../../../data/models/product.model.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key, required this.product});

  final Products product;

  // --- HELPER: Fix Image URLs ---
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/400";
    }
    if (path.startsWith("http")) {
      if (Platform.isAndroid) {
        return path
            .replaceAll('127.0.0.1', '10.0.2.2')
            .replaceAll('localhost', '10.0.2.2');
      }
      return path;
    }
    return path;
  }

  // --- 2. HELPER: Launch Telegram ---
  Future<void> _launchTelegram(String? username) async {
    if (username == null || username.isEmpty) {
      Get.snackbar("Notice", "Seller hasn't provided a Telegram username",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Remove '@' if the user included it in the database
    final cleanUsername = username.replaceAll('@', '');
    final Uri url = Uri.parse("https://t.me/$cleanUsername");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not open Telegram",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF5252);
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Price", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    cartController.addToCart(product);
                    Get.snackbar(
                      "Cart Updated",
                      "${product.name} added successfully!",
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 350,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                autoPlay: true,
              ),
              items: [product.image, product.image].map((imgUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[50],
                      child: Image.network(
                        getImageUrl(imgUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Seller Info Section ---
                  if (product.shopkeeper != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.storefront, color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          product.shopkeeper?.shopName ?? "Official Store",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  Text(
                    product.name ?? "Product Name",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text("Product Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? "No description available.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
                  ),

                  // --- 3. CONTACT SHOPKEEPER BUTTON ---
                  const SizedBox(height: 25),
                  const Text("Contact Seller", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _launchTelegram(product.shopkeeper?.telegramUsername),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 15),
                          // Inside your Column...
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🟢 Display real Shop Name or fallback to Name
                                Text(
                                    product.shopkeeper?.shopName ?? product.shopkeeper?.name ?? "Official Seller",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                                ),
                                // 🟢 Display real Telegram Username
                                Text(
                                    product.shopkeeper?.telegramUsername != null
                                        ? "@${product.shopkeeper!.telegramUsername}"
                                        : "@not_available",
                                    style: TextStyle(color: Colors.blue[800], fontSize: 13)
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text("Select Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      return Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: size == 'M' ? primaryColor : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(size, style: TextStyle(color: size == 'M' ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}