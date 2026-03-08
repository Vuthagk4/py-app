import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:py_app/app/modules/cart/controllers/cart_controller.dart';

import '../../../../data/models/product.model.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key, required this.product});

  final Products product;

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/400";
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

  Future<void> _launchTelegram(String? username) async {
    if (username == null || username.isEmpty) {
      Get.snackbar("Notice", "Seller hasn't provided a Telegram username",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
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

    // 🟢 Initialize selected size from product's available sizes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSizes(product.sizes);
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: context.theme.textTheme.bodyMedium?.color, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined,
                color: context.theme.textTheme.bodyMedium?.color),
            onPressed: () {},
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(context.isDarkMode ? 0.2 : 0.05),
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
                  Text("Price",
                      style: TextStyle(
                          color: context.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey,
                          fontSize: 14)),
                  Text(
                    "\$${product.price}",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.theme.textTheme.bodyMedium?.color),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                // 🟢 Obx so button label updates when size changes
                child: Obx(() => ElevatedButton(
                  onPressed: () {
                    cartController.addToCart(
                      product,
                      size: controller.selectedSize.value, // 🟢 must be here
                    );
                    Get.snackbar(
                      "Cart Updated",
                      "${product.name} (Size: ${controller.selectedSize.value}) added!",
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "Add to Cart (${controller.selectedSize.value})",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel
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
                      color: context.isDarkMode
                          ? Colors.grey[900]
                          : Colors.grey[50],
                      child: Image.network(
                        getImageUrl(imgUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey),
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

                  // Seller Info
                  if (product.shopkeeper != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.storefront,
                            color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          product.shopkeeper?.shopName ?? "Official Store",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Product Name
                  Text(
                    product.name ?? "Product Name",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: context.theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 15),

                  // Product Details heading
                  Text("Product Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? "No description available.",
                    style: TextStyle(
                        color: context.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 15,
                        height: 1.5),
                  ),

                  // Contact Seller
                  const SizedBox(height: 25),
                  Text("Contact Seller",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () =>
                        _launchTelegram(product.shopkeeper?.telegramUsername),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? Colors.blue.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.send,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.shopkeeper?.shopName ??
                                      product.shopkeeper?.name ??
                                      "Official Seller",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: context.theme.textTheme
                                          .bodyMedium?.color),
                                ),
                                Text(
                                  product.shopkeeper?.telegramUsername != null
                                      ? "@${product.shopkeeper!.telegramUsername}"
                                      : "@not_available",
                                  style: TextStyle(
                                      color: context.isDarkMode
                                          ? Colors.blue[300]
                                          : Colors.blue[800],
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14,
                              color: context.isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue),
                        ],
                      ),
                    ),
                  ),

                  // 🟢 Size Selector — real sizes from API
                  const SizedBox(height: 25),
                  Text("Select Size",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 12),

                  // 🟢 Show message if no sizes from backend
                  if (product.sizes == null || product.sizes!.isEmpty)
                    Text(
                      "No sizes available",
                      style: TextStyle(
                          color: context.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[400],
                          fontSize: 14),
                    )
                  else
                    Obx(() => Wrap(
                      // 🟢 Wrap handles overflow if many sizes
                      spacing: 10,
                      runSpacing: 10,
                      children: (product.sizes ?? ['S', 'M', 'L', 'XL'])
                          .map((size) {
                        final isSelected =
                            controller.selectedSize.value == size;
                        return GestureDetector(
                          onTap: () => controller.selectSize(size),
                          child: AnimatedContainer(
                            // 🟢 Smooth animation on select
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : context.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                              // 🟢 Glow effect on selected size
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color:
                                  primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                                  : [],
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : context.theme.textTheme
                                      .bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                        );
                      }).toList(),
                    )),

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