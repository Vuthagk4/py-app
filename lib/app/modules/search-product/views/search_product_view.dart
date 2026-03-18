import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../data/models/product.model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../Wishlist/controllers/wishlist_controller.dart';
import '../controllers/search_product_controller.dart';

class SearchProductView extends GetView<SearchProductController> {
  SearchProductView({super.key});

  final TextEditingController _searchCtrl   = TextEditingController();
  final TextEditingController _minPriceCtrl = TextEditingController();
  final TextEditingController _maxPriceCtrl = TextEditingController();

  // ── Palette — exactly matches HomeView ────────────────────────────────────
  static const Color _accent     = Color(0xFFFF5252);
  static const Color _accentDark = Color(0xFFFF1744);
  static const Color _bgLight    = Color(0xFFF2F3F7);
  static const Color _bgDark     = Color(0xFF0A0A0A);
  static const Color _cardLight  = Colors.white;
  static const Color _cardDark   = Color(0xFF1A1A1A);
  static const Color _gold       = Color(0xFFFFD700);

  // Header gradient — same as HomeView header
  static const List<Color> _headerGradient = [
    Color(0xFF1A0000),
    Color(0xFF3D0000),
    Color(0xFFFF5252),
  ];

  // ✅ Fix image URL — same as HomeView
  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/300";
    }
    if (path.startsWith("http")) {
      return path
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }
    return "http://10.0.2.2/storage/$path";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: isDark ? _bgDark : _bgLight,
      body: Column(
        children: [
          _buildHeader(context, isDark),
          _buildCategoryChips(isDark),
          Expanded(child: _buildBody(isDark)),
        ],
      ),
    );
  }

  // ─── HEADER — same gradient as HomeView ────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: _headerGradient,
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
              // ── Top row ──
              Row(
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Discover",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "Find what you love 🔍",
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Filter button
                  GestureDetector(
                    onTap: () => _showFilterSheet(),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Search bar — same style as HomeView ──
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      HapticFeedback.lightImpact();
                      controller.isSearch.value = true;
                      controller.searchProduct(search: v.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    hintStyle: TextStyle(
                        color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: _accent, size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel_rounded,
                          color: Colors.grey[400], size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        controller.clearSearch();
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CATEGORY CHIPS — same style as HomeView category bar ─────────────────
  final List<String> _chips = [
    "All", "Men", "Women", "Kids", "Sale", "New"
  ];
  final RxInt _selectedChip = 0.obs;

  Widget _buildCategoryChips(bool isDark) {
    return Container(
      color: isDark ? _bgDark : _bgLight,
      height: 54,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        itemBuilder: (_, i) => Obx(() {
          final selected = _selectedChip.value == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                _selectedChip.value = i;
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? _accent
                      : (isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: selected
                      ? [
                    const BoxShadow(
                      color: Color(0x55FF5252),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  _chips[i],
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark
                        ? Colors.grey[300]
                        : Colors.grey[700]),
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── BODY ──────────────────────────────────────────────────────────────────
  Widget _buildBody(bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeleton(isDark);
      }
      if (!controller.isSearch.value &&
          controller.products.isEmpty) {
        return _buildInitialState(isDark);
      }
      if (controller.isSearch.value &&
          controller.products.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return RefreshIndicator(
        color: _accent,
        backgroundColor:
        isDark ? const Color(0xFF1A1A1A) : Colors.white,
        onRefresh: () async => controller.searchProduct(
            search: _searchCtrl.text),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Results count
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                            "${controller.products.length}",
                            style: const TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: " results found",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_minPriceCtrl.text.isNotEmpty ||
                        _maxPriceCtrl.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: const Text("Filtered",
                            style: TextStyle(
                                color: _accent,
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            ),

            // Grid
            SliverPadding(
              padding:
              const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemBuilder: (context, index) =>
                    _buildProductCard(
                        context,
                        controller.products[index],
                        isDark),
                childCount: controller.products.length,
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 100)),
          ],
        ),
      );
    });
  }

  // ─── PRODUCT CARD — same style as HomeView ─────────────────────────────────
  Widget _buildProductCard(
      BuildContext context, Products product, bool isDark) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed('/product-detail', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
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
                // ✅ CachedNetworkImage
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl(product.image),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration:
                    const Duration(milliseconds: 300),
                    placeholder: (c, u) => Container(
                      height: 140,
                      color: isDark
                          ? const Color(0xFF252525)
                          : Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accent,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (c, u, e) => Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF252525)
                            : Colors.grey[100],
                        borderRadius:
                        const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: const Center(
                        child: Icon(
                            Icons
                                .image_not_supported_outlined,
                            color: Colors.grey,
                            size: 32),
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

                // Wishlist heart
                Positioned(
                  top: 10, right: 10,
                  child: Obx(() {
                    final wishCtrl =
                    Get.find<WishlistController>();
                    final liked =
                    wishCtrl.isWishlisted(product);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        wishCtrl.toggleWishlist(product);
                      },
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: liked
                              ? _accent
                              : Colors.white
                              .withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 14,
                          color: liked
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    );
                  }),
                ),

                // Price badge
                Positioned(
                  bottom: 8, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accent,
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

            // Info
            Padding(
              padding:
              const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: _gold),
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
                              colors: [_accent, _accentDark],
                            ),
                            borderRadius:
                            BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x44FF5252),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
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
          ],
        ),
      ),
    );
  }

  // ─── SKELETON LOADER ───────────────────────────────────────────────────────
  Widget _buildSkeleton(bool isDark) {
    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      itemCount: 6,
      itemBuilder: (_, i) => _PulseWidget(
        child: Container(
          height: i.isEven ? 220 : 190,
          decoration: BoxDecoration(
            color: isDark ? _cardDark : _cardLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: i.isEven ? 140 : 110,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252525)
                      : Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[200],
                        borderRadius:
                        BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 13,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[200],
                        borderRadius:
                        BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── INITIAL STATE ─────────────────────────────────────────────────────────
  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _accent.withOpacity(0.2)),
            ),
            child: const Icon(Icons.search_rounded,
                size: 40, color: _accent),
          ),
          const SizedBox(height: 20),
          Text(
            "Search for products",
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Type a name or use the filter",
            style:
            TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _accent.withOpacity(0.2)),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: _accent),
          ),
          const SizedBox(height: 20),
          Text(
            "No results found",
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try different keywords or filters",
            style:
            TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              _minPriceCtrl.clear();
              _maxPriceCtrl.clear();
              controller.clearSearch();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text("Clear Search",
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FILTER SHEET ──────────────────────────────────────────────────────────
  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding:
                const EdgeInsets.only(top: 12, bottom: 20),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: _accent, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Price Filter",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                    child:
                    _priceField(_minPriceCtrl, "Min \$")),
                const SizedBox(width: 16),
                Expanded(
                    child:
                    _priceField(_maxPriceCtrl, "Max \$")),
              ],
            ),
            const SizedBox(height: 28),

            // Apply button — red gradient same as HomeView
            GestureDetector(
              onTap: () {
                Get.back();
                HapticFeedback.mediumImpact();
                controller.isSearch.value = true;
                controller.searchProduct(
                  search: _searchCtrl.text,
                  minPrice:
                  double.tryParse(_minPriceCtrl.text),
                  maxPrice:
                  double.tryParse(_maxPriceCtrl.text),
                );
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, _accentDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Show Results",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _priceField(
      TextEditingController ctrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(
                  color: Colors.grey, fontSize: 14),
              prefixText: "\$ ",
              prefixStyle: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w700),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PULSE ANIMATION ──────────────────────────────────────────────────────────
class _PulseWidget extends StatefulWidget {
  final Widget child;
  const _PulseWidget({required this.child});
  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _anim, child: widget.child);
}