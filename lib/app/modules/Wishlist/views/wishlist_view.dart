import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/product.model.dart';
import '../../Cart/controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  // ✅ Fixed — same as HomeView/CartView
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/150";
    }
    if (path.startsWith("http")) {
      // ✅ Replace 127.0.0.1 with emulator IP
      return path
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }
    return "http://10.0.2.2/storage/$path"; // emulator
    // return "http://192.168.x.x/storage/$path"; // real device
  }

  void _goToDetail(Products product) {
    Get.toNamed('/product-detail', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2F3F7),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.wishlistItems.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return _buildGrid(context, isDark);
            }),
          ),
        ],
      ),
    );
  }

  // ─── HEADER — HomeView gradient ────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A0000),
            Color(0xFF3D0000),
            Color(0xFFFF5252),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66FF5252),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16),
                    ),
                  ),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 14),
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
                "What are you\nsaving? ♡",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFFF5252).withOpacity(0.2)),
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  size: 44, color: Color(0xFFFF5252)),
            ),
            const SizedBox(height: 24),
            Text(
              "Nothing saved yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap the ♡ icon on any product\nto save it here for later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x44FF5252),
                        blurRadius: 16,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: const Text(
                  "Explore Products",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── GRID ──────────────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.65,
      ),
      itemCount: controller.wishlistItems.length,
      itemBuilder: (context, index) {
        final product = controller.wishlistItems[index];
        return _buildProductCard(product, isDark);
      },
    );
  }

  // ─── PRODUCT CARD — same style as HomeView ─────────────────────────────────
  Widget _buildProductCard(Products product, bool isDark) {
    return GestureDetector(
      onTap: () => _goToDetail(product),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black45
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  // ✅ CachedNetworkImage
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: getImageUrl(product.image),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      fadeInDuration:
                      const Duration(milliseconds: 300),
                      placeholder: (c, u) => Container(
                        color: isDark
                            ? const Color(0xFF252525)
                            : Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (c, u, e) => Container(
                        color: isDark
                            ? const Color(0xFF252525)
                            : Colors.grey[100],
                        child: const Center(
                          child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 30),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Remove from wishlist
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.toggleWishlist(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                            Icons.favorite_rounded,
                            size: 14,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  // Price badge on image
                  Positioned(
                    bottom: 8, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "\$${product.price}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ──
            Expanded(
              flex: 4,
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name ?? "Product",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 13,
                                color: Color(0xFFFFD700)),
                            const SizedBox(width: 3),
                            Text("4.8",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500])),
                          ],
                        ),

                        // Add to cart — same as HomeView
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Get.find<CartController>()
                                .addToCart(product);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF5252),
                                  Color(0xFFFF1744),
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x44FF5252),
                                    blurRadius: 8,
                                    offset: Offset(0, 3)),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded,
                                    color: Colors.white,
                                    size: 13),
                                SizedBox(width: 3),
                                Text("Cart",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.w700)),
                              ],
                            ),
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