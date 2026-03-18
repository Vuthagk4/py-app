import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:py_app/app/modules/Notification/controllers/notification_controller.dart';

import '../../../../data/models/product.model.dart';
import '../../../../routes/app_pages.dart';
import '../../../Wishlist/controllers/wishlist_controller.dart';
import '../../../cart/controllers/cart_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith("http")) return path;
    return "http://10.0.2.2/storage/$path"; // emulator
    // return "http://192.168.x.x/storage/$path"; // real device
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2F3F7),
      body: Obx(() {
        // ── Shimmer Loading ───────────────────────────────────────────────
        if (controller.isLoading.value &&
            controller.products.value.categories == null) {
          return Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => _buildShimmerCard(isDark),
                ),
              ),
            ],
          );
        }

        var categories = controller.products.value.categories ?? [];
        var featured = controller.products.value.featuredProducts ?? [];

        List<Products> categoryFiltered = [];
        if (controller.selectedCategoryId.value == 0) {
          for (var cat in categories) {
            if (cat.products != null) categoryFiltered.addAll(cat.products!);
          }
        } else {
          var selectedCat = categories.firstWhereOrNull(
                  (c) => c.id == controller.selectedCategoryId.value);
          if (selectedCat != null && selectedCat.products != null) {
            categoryFiltered.addAll(selectedCat.products!);
          }
        }

        List<Products> displayedProducts =
        categoryFiltered.where((product) {
          final query =
          (controller.searchQuery?.value ?? "").toLowerCase();
          return (product.name ?? "").toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFF5252),
                backgroundColor:
                isDark ? const Color(0xFF1A1A1A) : Colors.white,
                onRefresh: () async =>
                    controller.fechProduct(forceRefresh: true),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── Featured Banner ──────────────────────────────
                    if (controller.selectedCategoryId.value == 0 &&
                        (controller.searchQuery?.value.isEmpty ?? true) &&
                        featured.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildSectionTitle("✦ Special For You",
                                categoryId: 0),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: featured.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                                itemBuilder: (context, index) =>
                                    _buildFeaturedCard(featured[index]),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                    // ── Category Chips ────────────────────────────────
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryHeaderDelegate(
                        child: _buildCategoryBar(
                            context, isDark, categories),
                      ),
                    ),

                    // ── All Products Title ────────────────────────────
                    if (controller.selectedCategoryId.value != 0 ||
                        !(controller.searchQuery?.value.isEmpty ?? true) ||
                        featured.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _buildSectionTitle("All Products",
                              categoryId:
                              controller.selectedCategoryId.value),
                        ),
                      ),

                    // ── Product Grid ──────────────────────────────────
                    displayedProducts.isEmpty
                        ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 60,
                                color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text("No products found",
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                        : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 16, 16, 0),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        itemBuilder: (context, index) {
                          final product =
                          displayedProducts[index];
                          return GestureDetector(
                            onTap: () =>
                                controller.goToDetail(product),
                            child: _buildProductCard(
                                context, product, isDark),
                          );
                        },
                        childCount: displayedProducts.length,
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── SHIMMER CARD (zero packages — pure Flutter) ───────────────────────────
  Widget _buildShimmerCard(bool isDark) {
    return _PulseAnimation(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 13,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 13,
                    width: 90,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 28,
                        width: 64,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    final notifController = Get.find<NotificationController>();

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
              offset: Offset(0, 10)),
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
                  // Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD700),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Deliver to",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white, size: 15),
                          const SizedBox(width: 4),
                          const Text(
                            "Phnom Penh, KH",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more_rounded,
                              color: Colors.white70, size: 18),
                        ],
                      ),
                    ],
                  ),

                  // Notification + Cart
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.CART),
                        child: Obx(() {
                          final cartCtrl =
                          Get.find<CartController>();
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white
                                          .withOpacity(0.15)),
                                ),
                                child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 20),
                              ),
                              if (cartCtrl.cartItems.isNotEmpty)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.all(4),
                                    decoration:
                                    const BoxDecoration(
                                        color:
                                        Color(0xFFFFD700),
                                        shape:
                                        BoxShape.circle),
                                    child: Text(
                                      '${cartCtrl.cartItems.length}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () =>
                            Get.toNamed(Routes.NOTIFICATION),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.15)),
                              ),
                              child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 20),
                            ),
                            Obx(() {
                              if (notifController.unreadCount ==
                                  0) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding:
                                  const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFFD700),
                                      shape: BoxShape.circle),
                                  constraints:
                                  const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18),
                                  child: Center(
                                    child: Text(
                                      '${notifController.unreadCount}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "What are you\nlooking for? 👀",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color:
                              Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Obx(() => TextField(
                        onChanged: (value) =>
                            controller.searchProducts(value),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14),
                          prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFFF5252),
                              size: 22),
                          suffixIcon: controller
                              .searchQuery.value.isEmpty
                              ? null
                              : IconButton(
                            icon: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.grey,
                                size: 18),
                            onPressed: () =>
                                controller.clearSearch(),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: 15),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CATEGORY BAR ──────────────────────────────────────────────────────────
  Widget _buildCategoryBar(
      BuildContext context, bool isDark, List categories) {
    return Container(
      color:
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2F3F7),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          bool isAll = index == 0;
          int id = isAll ? 0 : categories[index - 1].id!;
          String name =
          isAll ? "All" : categories[index - 1].name!;
          bool isSelected =
              controller.selectedCategoryId.value == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.changeCategory(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF5252)
                      : (isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected
                      ? [
                    const BoxShadow(
                        color: Color(0x55FF5252),
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ]
                      : [
                    BoxShadow(
                        color:
                        Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                        ? Colors.grey[300]
                        : Colors.grey[700]),
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── PRODUCT CARD ──────────────────────────────────────────────────────────
  Widget _buildProductCard(
      BuildContext context, Products product, bool isDark) {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: getImageUrl(product.image),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fadeInDuration:
                  const Duration(milliseconds: 300),
                  placeholder: (context, url) => Container(
                    height: 140,
                    color: isDark
                        ? const Color(0xFF252525)
                        : Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252525)
                              : Colors.grey[100],
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: const Center(
                          child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 32),
                        ),
                      ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
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
              Positioned(
                top: 10,
                right: 10,
                child: Obx(() {
                  final wishlistCtrl =
                  Get.find<WishlistController>();
                  final isLiked =
                  wishlistCtrl.isWishlisted(product);
                  return GestureDetector(
                    onTap: () =>
                        wishlistCtrl.toggleWishlist(product),
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? const Color(0xFFFF5252)
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: isLiked
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }),
              ),
              Positioned(
                bottom: 8,
                left: 10,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text(
                          "4.8",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.find<CartController>()
                              .addToCart(product),
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
                                color: Colors.white, size: 13),
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
        ],
      ),
    );
  }

  // ─── FEATURED CARD ─────────────────────────────────────────────────────────
  Widget _buildFeaturedCard(dynamic product) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF2A0A0A),
            Color(0xFF3D0000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x55FF5252),
              blurRadius: 20,
              offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "⚡ Limited Time",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Special\nOffer",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        "Up to 40%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(22),
                        ),
                        child: const Text(
                          "Claim Now →",
                          style: TextStyle(
                            color: Color(0xFFFF5252),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: getImageUrl(product.image),
                      fit: BoxFit.cover,
                      height: double.infinity,
                      fadeInDuration:
                      const Duration(milliseconds: 300),
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[800]),
                      errorWidget: (context, url, error) =>
                      const Center(
                        child: Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white30,
                            size: 32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTION TITLE ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, {int categoryId = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(
              Routes.SEE_ALL,
              arguments: {
                'categoryId': categoryId,
                'categoryName': title,
              },
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "See All",
                style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PULSE ANIMATION (replaces Skeletonizer — zero dependencies) ───────────────
class _PulseAnimation extends StatefulWidget {
  final Widget child;
  const _PulseAnimation({required this.child});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

// ─── CATEGORY HEADER DELEGATE ──────────────────────────────────────────────────
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoryHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) =>
      child;

  @override
  double get maxExtent => 54;

  @override
  double get minExtent => 54;

  @override
  bool shouldRebuild(
      covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}