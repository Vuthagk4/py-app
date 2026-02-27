import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../data/models/product.model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/search_product_controller.dart';

class SearchProductView extends GetView<SearchProductController> {
  SearchProductView({super.key});

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  // 🟢 Fixed Colors to ignore Dark Mode
  final Color primaryColor = const Color(0xFFFF5252);
  final Color lightBackgroundColor = const Color(0xFFF8F9FA);
  final Color pureWhite = Colors.white;

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith("http") && Platform.isAndroid) {
      return path.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 We use Theme() to wrap the scaffold and force a Light Brightness for this page only
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: Scaffold(
        backgroundColor: lightBackgroundColor,
        appBar: AppBar(
          backgroundColor: pureWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Discover',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 22),
          ),
        ),
        body: Column(
          children: [
            // --- 1. SEARCH BAR & FILTER ROW ---
            Container(
              color: pureWhite,
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNewSearchField(),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterButton(context),
                ],
              ),
            ),

            // --- 2. SEARCH RESULTS AREA ---
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }

                if (!controller.isSearch.value && controller.products.isEmpty) {
                  return _buildInitialState();
                }

                if (controller.isSearch.value && controller.products.isEmpty) {
                  return _buildEmptyState();
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.products.length} Items found',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                            if (minPriceController.text.isNotEmpty || maxPriceController.text.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text("Filtered", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemBuilder: (context, index) {
                          final product = controller.products[index];
                          return _buildPinterestCard(product);
                        },
                        childCount: controller.products.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinterestCard(Products product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    getImageUrl(product.image),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey[100], child: const Icon(Icons.broken_image)),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: const Icon(Icons.favorite_border, size: 16, color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? "Product",
                    maxLines: 2,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Dynamic shopkeeper check for safety
                          int? shopId = product.shopkeeperId ?? product.shopkeeper?.id;
                          if (shopId == null) {
                            Get.snackbar(
                                "Store Error",
                                "This item is not linked to a valid shopkeeper.",
                                backgroundColor: Colors.orange,
                                colorText: Colors.white
                            );
                            return;
                          }
                          Get.find<CartController>().addToCart(product);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 14),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        height: 48, width: 48,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildNewSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.black), // Force black text
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            controller.isSearch.value = true;
            controller.searchProduct(search: value);
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          hintText: "Search products...",
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.cancel, size: 18, color: Colors.grey), onPressed: () => searchController.clear())
              : null,
        ),
      ),
    );
  }

  // --- Utility Views ---
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Find your next favorite item", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 15),
          const Text("We couldn't find a match", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            const Text("Price Filter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black)),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: _buildPriceInput(minPriceController, "Min")),
                const SizedBox(width: 20),
                Expanded(child: _buildPriceInput(maxPriceController, "Max")),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.isSearch.value = true;
                  controller.searchProduct(
                    search: searchController.text,
                    minPrice: double.tryParse(minPriceController.text),
                    maxPrice: double.tryParse(maxPriceController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: const Text("Show Results", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixText: "\$ ",
            prefixStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}