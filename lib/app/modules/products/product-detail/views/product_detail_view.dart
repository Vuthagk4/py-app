import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/product.model.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  // Keeping your logic: passing the product directly via the constructor
  const ProductDetailView({super.key, required this.product});

  final Products product;

  // --- HELPER: Fix Image URLs for Android Emulator ---
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/400";
    }
    if (path.startsWith("http")) {
      if (Platform.isAndroid) {
        return path.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
      }
      return path;
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF5252); // Brand Red Color

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // --- 1. APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              Get.snackbar("Favorites", "Added to your favorites!", snackPosition: SnackPosition.BOTTOM);
            },
          )
        ],
      ),

      // --- 2. BOTTOM ACTION BAR (Price & Add to Cart) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Your Price Logic moved here for a cleaner look
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Price", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    "Success",
                    "Added to Cart!",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                label: const Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              )
            ],
          ),
        ),
      ),

      // --- 3. MAIN SCROLLABLE BODY ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- IMAGE & THUMBNAILS ---
            SizedBox(
              height: 380,
              child: Stack(
                children: [
                  // Main Image using your logic
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Image.network(
                        getImageUrl(product.image),
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),

                  // Thumbnails Row (Mocked based on your design)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildThumbnail(getImageUrl(product.image), isActive: true),
                        _buildThumbnail(getImageUrl(product.image)),
                        _buildThumbnail(getImageUrl(product.image)),
                        _buildThumbnailCount("+10"),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- DETAILS SECTION (White Card) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Clothes", // Or map to category if you have it
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text("4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Your Name Logic
                  Text(
                    product.name ?? "Product Name",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Seller Info Row (Static for UI design)
                  const Text("Seller", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage("https://img.freepik.com/free-photo/young-beautiful-woman-pink-warm-sweater-natural-look-smiling-portrait-isolated-long-hair_285396-896.jpg"),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Jenny Doe", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Manager", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.chat_bubble_outline, color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.phone_outlined, color: primaryColor, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Your Description Logic
                  const Text("Product Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 14),
                      children: [
                        TextSpan(text: product.description ?? "No description available."),
                        const TextSpan(text: " Read more", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Select Size
                  const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: ["S", "M", "L", "XL"].map((size) {
                      return Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: size == "M" ? primaryColor : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                            size,
                            style: TextStyle(
                                color: size == "M" ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS FOR THUMBNAILS ---

  Widget _buildThumbnail(String url, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.white,
          border: isActive ? Border.all(color: const Color(0xFFFF5252), width: 2) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isActive) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(url, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image, size: 20))),
      ),
    );
  }

  Widget _buildThumbnailCount(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}