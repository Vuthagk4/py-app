import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:py_app/app/modules/cart/controllers/cart_controller.dart';

import '../../../../data/models/product.model.dart';
import '../../../Wishlist/controllers/wishlist_controller.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key, required this.product});

  final Products product;

  static const Color primary = Color(0xFFFF3D57);
  static const Color dark    = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBg  = Color(0xFF222222);
  static const Color muted   = Color(0xFF888888);

  // ✅ Fixed: works for both emulator (10.0.2.2) and real device
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/400";
    }
    if (path.startsWith("http")) {
      // ✅ Fix emulator IP — Laravel returns 127.0.0.1 but emulator needs 10.0.2.2
      return path
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }
    return "http://10.0.2.2/storage/$path";
  }

  Future<void> _launchTelegram(String? username) async {
    if (username == null || username.isEmpty) {
      Get.snackbar(
        "Notice",
        "Seller hasn't provided a Telegram username",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardBg,
        colorText: Colors.white,
      );
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

    // ✅ Init sizes once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSizes(product.sizes);
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ✅ Build image list for carousel
    // If your API returns multiple images in future, replace this with product.images
    // For now: show same image in 3 slides so carousel slides properly
    final List<String?> images = product.image != null
        ? [product.image, product.image, product.image]
        : ["https://via.placeholder.com/400"];

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
          // ✅ Wishlist button — wired up
          // ── Wishlist button ──
          Positioned(
            top: 10,
            right: 10,
            child: Obx(() {
              final wishlistCtrl = Get.find<WishlistController>();
              final isLiked = wishlistCtrl.isWishlisted(product);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  wishlistCtrl.toggleWishlist(product);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? const Color(0xFFFF5252)
                        : Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLiked
                          ? const Color(0xFFFF5252)
                          : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isLiked
                            ? const Color(0xFFFF5252).withOpacity(0.5)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: isLiked ? 14 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isLiked),
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),

// ── Share button ──
          Positioned(
            top: 10,
            right: 58, // sits left of the wishlist button
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // add share logic here
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
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
            // ── Hero Image Carousel ──────────────────────────────
            _buildCarousel(images),

            // ── Content ─────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: dark,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
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

  // ── Carousel ───────────────────────────────────────────────────────────────
  Widget _buildCarousel(List<String?> images) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 420,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,  // ✅ loops forever
            autoPlay: true,              // ✅ auto slides
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOutCubic,
            onPageChanged: (index, _) {
              controller.carouselIndex.value = index;
            },
          ),
          items: images.map((imgUrl) {
            return Container(
              width: double.infinity,
              color: const Color(0xFF111111),
              // ✅ CachedNetworkImage instead of Image.network
              child: CachedNetworkImage(
                imageUrl: getImageUrl(imgUrl),
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image,
                      size: 60, color: Colors.grey),
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
                colors: [
                  Colors.transparent,
                  dark.withOpacity(0.95),
                ],
              ),
            ),
          ),
        ),

        // ✅ Dot indicators — reactive with Obx
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final isActive = i == controller.carouselIndex.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? primary
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          )),
        ),
      ],
    );
  }

  // ── Top row: brand + badge ──────────────────────────────────────────────────
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
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── Product name ────────────────────────────────────────────────────────────
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

  // ── Stats row ───────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statChip(Icons.star_rounded, "4.8", Colors.amber),
        const SizedBox(width: 10),
        _statChip(Icons.shopping_bag_outlined, "238 sold", muted),
        const SizedBox(width: 10),
        _statChip(
            Icons.local_shipping_outlined, "Free ship", Colors.green),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Size section ────────────────────────────────────────────────────────────
  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Select Size",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            Text(
              "Size guide",
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: primary,
              ),
            ),
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
            children: (product.sizes ?? ['S', 'M', 'L', 'XL'])
                .map((size) {
              final isSelected =
                  controller.selectedSize.value == size;
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

  Widget _buildDescriptionSection() {
    final String desc = (product.description != null &&
        product.description!.trim().isNotEmpty)
        ? product.description!.trim()
        : "No description available for this product.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            desc,
            style: TextStyle(
              color: product.description != null
                  ? Colors.white.withOpacity(0.65)
                  : Colors.white.withOpacity(0.3),
              fontSize: 14,
              height: 1.7,
              fontStyle: product.description != null
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  // ── Seller card ─────────────────────────────────────────────────────────────
  Widget _buildSellerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Seller",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () =>
              _launchTelegram(product.shopkeeper?.telegramUsername),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border:
              Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0088CC),
                        Color(0xFF00AAFF),
                      ],
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

  // ── Bottom bar ──────────────────────────────────────────────────────────────
  Widget _buildBottomBar(CartController cartController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
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
                  style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 0.5)),
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
                    colors: [
                      Color(0xFFFF3D57),
                      Color(0xFFFF6B35),
                    ],
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