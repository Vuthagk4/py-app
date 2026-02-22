import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product.model.dart';
import '../controllers/search_product_controller.dart';

class SearchProductView extends GetView<SearchProductController> {
  SearchProductView({super.key});

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  final Color primaryColor = const Color(0xFFFF5252);

  // --- HELPER: Fix Image URLs for Android Emulator ---
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith("http") && Platform.isAndroid) {
      return path.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. SEARCH BAR & FILTER ROW ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchField(
                    controller: searchController,
                    submit: (value) {
                      if (value.isNotEmpty) {
                        controller.isSearch.value = true;
                        controller.searchProduct(search: value);
                      }
                    },
                    cancelSearch: () {
                      searchController.clear();
                      controller.isSearch.value = false;
                      controller.products.clear(); // Clear results
                    },
                  ),
                ),
                const SizedBox(width: 15),
                // Filter Button
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.tune, color: primaryColor),
                  ),
                )
              ],
            ),
          ),

          // --- 2. SEARCH RESULTS AREA ---
          Expanded(
            child: Obx(() {
              // A. Loading State
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: primaryColor));
              }

              // B. Initial State (Hasn't searched yet)
              if (!controller.isSearch.value && controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 15),
                      Text("What are you looking for?", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                    ],
                  ),
                );
              }

              // C. No Results Found
              if (controller.isSearch.value && controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 15),
                      Text("No products found.", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                    ],
                  ),
                );
              }

              // D. List of Found Products
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results Count Header
                  if (controller.isSearch.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Found ${controller.products.length} results',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () {
                              searchController.clear();
                              controller.isSearch.value = false;
                              controller.products.clear();
                            },
                            child: Text("Clear", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),

                  // The List View
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      itemCount: controller.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return _buildSearchProductCard(product);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET COMPONENTS =================

  // Modern Horizontal Product Card for Search Results
  Widget _buildSearchProductCard(Products product) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-detail', arguments: product);
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                child: Image.network(
                  getImageUrl(product.image),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      product.name ?? "Product",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      product.description ?? "No description",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- FILTER BOTTOM SHEET ---
  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filter Options", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Min Price",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Text("-", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Max Price",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close sheet
                  controller.isSearch.value = true;

                  // Run search with the price filters applied
                  controller.searchProduct(
                    search: searchController.text,
                    minPrice: double.tryParse(minPriceController.text),
                    maxPrice: double.tryParse(maxPriceController.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ================= CUSTOM SEARCH FIELD =================
// Renamed slightly to avoid conflicts with Flutter's built-in SearchBar
class CustomSearchField extends StatefulWidget {
  final Function(String)? submit;
  final TextEditingController controller;
  final Function()? cancelSearch;

  const CustomSearchField({
    super.key,
    this.submit,
    required this.controller,
    this.cancelSearch,
  });

  @override
  _CustomSearchFieldState createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15), // Matches your other inputs
      ),
      child: TextFormField(
        controller: widget.controller,
        onChanged: (val) {
          setState(() {}); // Updates UI to show/hide the 'X' clear icon
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () {
              if (widget.cancelSearch != null) widget.cancelSearch!();
              setState(() {
                widget.controller.clear();
              });
            },
          )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onFieldSubmitted: widget.submit,
      ),
    );
  }
}