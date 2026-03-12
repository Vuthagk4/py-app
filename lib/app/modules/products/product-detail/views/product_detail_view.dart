import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:py_app/app/modules/cart/controllers/cart_controller.dart';

import '../../../../data/models/product.model.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key, required this.product});

  final Products product;

  static const Color primary = Color(0xFFFF3D57);
  static const Color dark = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF222222);
  static const Color muted = Color(0xFF888888);

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
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: cardBg,
          colorText: Colors.white);
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
    final CartController cartController = Get.find<CartController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSizes(product.sizes);
    });

    // Force dark status bar icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: dark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.favorite_border,
                  color: Colors.white, size: 18),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.share_outlined,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(cartController),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image Carousel ──
            _buildCarousel(),

            // ── Content ──
            Container(
              decoration: const BoxDecoration(
                color: dark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(),
                    const SizedBox(height: 6),
                    _buildProductName(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildSizeSection(),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),
                    _buildSellerCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carousel ──────────────────────────────────────────────
  Widget _buildCarousel() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 420,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOutCubic,
          ),
          items: [product.image, product.image].map((imgUrl) {
            return Container(
              width: double.infinity,
              color: const Color(0xFF111111),
              child: Image.network(
                getImageUrl(imgUrl),
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(
                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
        // Bottom gradient fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, dark.withOpacity(0.95)],
              ),
            ),
          ),
        ),
        // Dot indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == 0 ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == 0 ? primary : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ),
      ],
    );
  }

  // ── Top row: brand + badge ────────────────────────────────
  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (product.shopkeeper != null)
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                product.shopkeeper?.shopName ?? "Official Store",
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withOpacity(0.3)),
          ),
          child: const Text(
            "IN STOCK",
            style: TextStyle(
              color: primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  // ── Product name ──────────────────────────────────────────
  Widget _buildProductName() {
    return Text(
      product.name ?? "Product Name",
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1.15,
        letterSpacing: -0.5,
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statChip(Icons.star_rounded, "4.8", Colors.amber),
        const SizedBox(width: 10),
        _statChip(Icons.shopping_bag_outlined, "238 sold", muted),
        const SizedBox(width: 10),
        _statChip(Icons.local_shipping_outlined, "Free ship", Colors.green),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Size section ──────────────────────────────────────────
  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Select Size",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            Text("Size guide",
                style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: primary)),
          ],
        ),
        const SizedBox(height: 14),
        if (product.sizes == null || product.sizes!.isEmpty)
          Text("No sizes available",
              style: TextStyle(color: muted, fontSize: 14))
        else
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (product.sizes ?? ['S', 'M', 'L', 'XL']).map((size) {
              final isSelected = controller.selectedSize.value == size;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.selectSize(size);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 58,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? primary : cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
      ],
    );
  }

  // ── Description ───────────────────────────────────────────
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            product.description ?? "No description available.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  // ── Seller card ───────────────────────────────────────────
  Widget _buildSellerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Seller",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _launchTelegram(product.shopkeeper?.telegramUsername),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0088CC), Color(0xFF00AAFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.shopkeeper?.shopName ??
                            product.shopkeeper?.name ??
                            "Official Seller",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.shopkeeper?.telegramUsername != null
                            ? "@${product.shopkeeper!.telegramUsername}"
                            : "Tap to contact",
                        style: const TextStyle(
                          color: Color(0xFF0088CC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0088CC).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: Color(0xFF0088CC)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────
  Widget _buildBottomBar(CartController cartController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          // Price block
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Price",
                  style: TextStyle(color: muted, fontSize: 11, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(
                "\$${product.price}",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Add to cart button
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                cartController.addToCart(
                  product,
                  size: controller.selectedSize.value,
                );
                Get.snackbar(
                  "Added to Cart ✓",
                  "${product.name} · Size ${controller.selectedSize.value}",
                  backgroundColor: cardBg,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 14,
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: primary),
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3D57), Color(0xFFFF6B35)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Add to Cart · ${controller.selectedSize.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}