import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../data/models/product.model.dart';
import '../../../../routes/app_pages.dart';
import '../../../cart/controllers/cart_controller.dart';
import '../../product-detail/views/product_detail_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value && controller.products.value.categories == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5252)));
        }

        var categories = controller.products.value.categories ?? [];
        var featured = controller.products.value.featuredProducts ?? [];

        // --- 1. FILTER BY CATEGORY ---
        List<Products> categoryFiltered = [];
        if (controller.selectedCategoryId.value == 0) {
          for (var cat in categories) {
            if (cat.products != null) categoryFiltered.addAll(cat.products!);
          }
        } else {
          var selectedCat = categories.firstWhereOrNull((c) => c.id == controller.selectedCategoryId.value);
          if (selectedCat != null && selectedCat.products != null) {
            categoryFiltered.addAll(selectedCat.products!);
          }
        }

        // --- 2. FILTER BY SEARCH QUERY ---
        List<Products> displayedProducts = categoryFiltered.where((product) {
          final query = (controller.searchQuery?.value ?? "").toLowerCase();
          return (product.name ?? "").toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFF5252),
                onRefresh: () async => controller.fechProduct(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // A. Special Offers (Hide when searching or filtering)
                    if (controller.selectedCategoryId.value == 0 &&
                        (controller.searchQuery?.value.isEmpty ?? true) &&
                        featured.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Special For You"),
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: featured.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 15),
                                itemBuilder: (context, index) => _buildSpecialOfferCard(featured[index]),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                    // B. PINNED CATEGORY BAR
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryHeaderDelegate(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length + 1,
                            itemBuilder: (context, index) {
                              bool isAll = index == 0;
                              int id = isAll ? 0 : categories[index - 1].id!;
                              String name = isAll ? "All" : categories[index - 1].name!;
                              bool isSelected = controller.selectedCategoryId.value == id;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(name),
                                  selected: isSelected,
                                  onSelected: (val) => controller.changeCategory(id),
                                  selectedColor: const Color(0xFFFF5252),
                                  labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                  ),
                                  backgroundColor: Colors.grey[100],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  side: BorderSide.none,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // C. THE PINTEREST GRID
                    displayedProducts.isEmpty
                        ? const SliverFillRemaining(child: Center(child: Text("No products found")))
                        : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        itemBuilder: (context, index) {
                          final product = displayedProducts[index];
                          return GestureDetector(
                            onTap: () => controller.goToDetail(product),
                            child: _buildPinterestProductCard(product),
                          );
                        },
                        childCount: displayedProducts.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 50)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Pinterest Style Product Card ---
  Widget _buildPinterestProductCard(Products product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  getImageUrl(product.image),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey[100], child: const Icon(Icons.image)),
                ),
              ),
              const Positioned(
                top: 8, right: 8,
                child: CircleAvatar(
                  radius: 12, backgroundColor: Colors.white,
                  child: Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name ?? "Product", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$${product.price}", style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold, fontSize: 15)),
                    GestureDetector(
                      onTap: () => Get.put(CartController()).addToCart(product),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

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
                  child: Obx(() {
                    // We use a TextEditingController or a Key to force the text field to clear visually
                    return TextField(
                      onChanged: (value) => controller.searchProducts(value),
                      // 🟢 This controller logic ensures the text physically disappears when cleared
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.searchQuery.value,
                          selection: TextSelection.collapsed(offset: controller.searchQuery.value.length),
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        // 🟢 Dynamic Suffix Icon
                        suffixIcon: controller.searchQuery.value.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () => controller.clearSearch(),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    );
                  }),
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

  Widget _buildSectionHeader(String title, {String buttonText = "See All", VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (buttonText.isNotEmpty)
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
              child: Image.network(getImageUrl(product.image), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white54)),
            ),
          )
        ],
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoryHeaderDelegate({required this.child});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  double get maxExtent => 50;
  @override
  double get minExtent => 50;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}