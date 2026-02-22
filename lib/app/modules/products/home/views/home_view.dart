import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/product.model.dart';
import '../../../cart/controllers/cart_controller.dart';
import '../../product-detail/views/product_detail_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // --- HELPER: Fix Image URLs for Android Emulator ---
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/150";
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
    return Scaffold(
      backgroundColor: Colors.white,

      body: Obx(() {
        // 1. Loading State
        if (controller.isLoading.value && controller.products.value.categories == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)));
        }

        // 2. Extract Data
        var categories = controller.products.value.categories ?? [];
        var featured = controller.products.value.featuredProducts ?? [];

        // 3. Build UI
        return Column(
          children: [
            // --- CUSTOM HEADER ---
            _buildCustomHeader(),

            // --- SCROLLABLE BODY WITH REFRESH ---
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFF5252),
                onRefresh: () async => controller.fechProduct(),

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // --- A. Special For You (Featured Offers) ---
                      if (featured.isNotEmpty) ...[
                        _buildSectionHeader("Special For You"),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 15),
                            itemBuilder: (context, index) {
                              return _buildSpecialOfferCard(featured[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // --- B. DYNAMIC CATEGORY SECTIONS ---
                      // This loops through every category from your API
                      ...categories.map((category) {

                        // Hide the category if it doesn't have any products
                        if (category.products == null || category.products!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Category Title & "See more"
                            _buildSectionHeader(
                                category.name ?? "Category",
                                buttonText: "See more",
                                onTap: () {
                                  // You can navigate to a specific category page here later
                                  Get.snackbar("See More", "View all ${category.name} products");
                                }
                            ),

                            // 2. Horizontal Product List for this category
                            SizedBox(
                              height: 240, // Fixed height for the horizontal cards
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: category.products!.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 15),
                                itemBuilder: (context, index) {
                                  final product = category.products![index];

                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => ProductDetailView(product: product));
                                    },
                                    child: _buildHorizontalProductCard(product),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        );
                      }).toList(), // End of category mapping

                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= WIDGET COMPONENTS =================

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFF5252),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("Phnom Penh, KH", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                    ],
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.tune, color: Color(0xFFFF5252)),
              )
            ],
          )
        ],
      ),
    );
  }

  // Updated Section Header to accept "onTap" for the See More button
  Widget _buildSectionHeader(String title, {String buttonText = "See All", VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onTap,
            child: Text(buttonText, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferCard(dynamic product) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1F1F), Color(0xFF383838)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text("Limited time!", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                const Text("Get Special Offer", style: TextStyle(color: Colors.white, fontSize: 16)),
                const Text("Up to 40%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFF5252), borderRadius: BorderRadius.circular(20)),
                  child: const Text("Claim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                getImageUrl(product.image),
                fit: BoxFit.cover,
                errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          )
        ],
      ),
    );
  }

  // New Product Card specifically designed for Horizontal Scrolling
  Widget _buildHorizontalProductCard(Products product) {
    return Container(
      width: 150, // Fixed width for horizontal scrolling
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    getImageUrl(product.image),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.image)),
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? "Product",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${product.price}",
                      style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    // --- UPDATED CLICKABLE BUTTON HERE ---
                    // --- INSIDE HomeView's _buildHorizontalProductCard ---

                    GestureDetector(
                      onTap: () {
                        // 🔴 THE FIX: Change Get.find to Get.put
                        final cartController = Get.put(CartController());

                        // Pass the product to the cart
                        cartController.addToCart(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF5252),
                            shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 12),
                      ),
                    )
                    // ------------------------------------

                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}