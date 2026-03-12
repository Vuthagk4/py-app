import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product.model.dart';
import '../../Cart/controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith("http")) return path;
    return "http://your-centos-ip/storage/$path";
  }

  void _goToDetail(Products product) {
    // Navigate to product detail — adjust route/arguments to match your app
    Get.toNamed('/product-detail', arguments: product);
    // OR if you use a controller method:
    // Get.find<HomeController>().goToDetail(product);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.wishlistItems.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildGrid(context, isDark);
            }),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x44FF5252), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 17),
                ),
              ),
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      "${controller.count} saved",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "My",
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const Text(
            "Wishlist ♡",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded, size: 55, color: Color(0xFFFF5252)),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nothing saved yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap the ♡ icon on any product to save it here for later.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Color(0x44FF5252), blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: const Text(
                  "Explore Products",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── GRID ─────────────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: controller.wishlistItems.length,
      itemBuilder: (context, index) {
        final product = controller.wishlistItems[index];
        return _buildProductCard(context, product, isDark);
      },
    );
  }

  // ─── PRODUCT CARD ─────────────────────────────────────────────────────────
  Widget _buildProductCard(BuildContext context, Products product, bool isDark) {
    return GestureDetector(
      onTap: () => _goToDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      getImageUrl(product.image),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[100],
                        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                      ),
                    ),
                  ),
                  // Remove from wishlist button
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => controller.toggleWishlist(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFF5252)),
                      ),
                    ),
                  ),
                  // "Tap to view" overlay hint
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name ?? "Product",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "\$${product.price}",
                              style: const TextStyle(
                                color: Color(0xFFFF5252),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Add to cart
                        GestureDetector(
                          onTap: () => Get.find<CartController>().addToCart(product),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0x44FF5252), blurRadius: 8, offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}