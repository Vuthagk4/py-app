import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // 🟢 Added this

import '../../../data/models/product.model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../products/product-detail/views/product_detail_view.dart';
import '../controllers/category_detail_controller.dart';

class CategoryDetailView extends GetView<CategoryDetailController> {
  final Categories? category;
  const CategoryDetailView({super.key, this.category});

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
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
    final selectedCategory = category ?? Get.arguments as Categories;
    final cartController = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          selectedCategory.name ?? "Category",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: selectedCategory.products == null || selectedCategory.products!.isEmpty
          ? _buildEmptyState()
          : MasonryGridView.count( // 🟢 Switched to Masonry Grid
        padding: const EdgeInsets.all(20),
        itemCount: selectedCategory.products!.length,
        crossAxisCount: 2,         // 2 columns
        mainAxisSpacing: 15,       // Vertical space
        crossAxisSpacing: 15,      // Horizontal space
        itemBuilder: (context, index) {
          final product = selectedCategory.products![index];
          return GestureDetector(
            onTap: () => Get.to(() => ProductDetailView(product: product)),
            child: _buildGridProductCard(product, cartController),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No products found in this category",
              style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  // --- WIDGET: Your original Grid Product Card style preserved ---
  Widget _buildGridProductCard(Products product, CartController cartController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              getImageUrl(product.image),
              width: double.infinity,
              fit: BoxFit.cover, // 🟢 Masonry grid uses this to determine height
              errorBuilder: (c, e, s) => Container(
                height: 100, // Fallback height for broken images
                color: Colors.grey[50],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? "Product",
                  maxLines: 2, // Allow a bit more space for Pinterest look
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${product.price}",
                      style: const TextStyle(
                        color: Color(0xFFFF5252),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cartController.addToCart(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5252),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}