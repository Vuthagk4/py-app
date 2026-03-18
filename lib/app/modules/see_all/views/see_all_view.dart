import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:py_app/app/data/models/product.model.dart';
import '../../Cart/controllers/cart_controller.dart';
import '../../Wishlist/controllers/wishlist_controller.dart';
import '../../products/home/controllers/home_controller.dart';

class SeeAllView extends StatefulWidget {
  const SeeAllView({super.key});

  @override
  State<SeeAllView> createState() => _SeeAllViewState();
}

class _SeeAllViewState extends State<SeeAllView> {
  late final HomeController homeCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _localSearch = "".obs;

  // Passed via Get.arguments: { 'categoryId': int, 'categoryName': String }
  late int _categoryId;
  late String _categoryName;

  @override
  void initState() {
    super.initState();
    homeCtrl = Get.find<HomeController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _categoryId = args['categoryId'] ?? 0;
    _categoryName = args['categoryName'] ?? 'All Products';
  }

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith("http")) return path;
    return "http://your-centos-ip/storage/$path";
  }

  List<Products> _getProducts() {
    final categories = homeCtrl.products.value.categories ?? [];
    List<Products> list = [];

    if (_categoryId == 0) {
      for (var cat in categories) {
        if (cat.products != null) list.addAll(cat.products!);
      }
    } else {
      final cat = categories.firstWhereOrNull((c) => c.id == _categoryId);
      if (cat?.products != null) list.addAll(cat!.products!);
    }

    final q = _localSearch.value.toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) => (p.name ?? "").toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2F3F7),
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: Obx(() {
              final products = _getProducts();
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text("No products found",
                          style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: const Color(0xFFFF5252),
                onRefresh: () async => homeCtrl.fechProduct(),
                child: MasonryGridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => homeCtrl.goToDetail(product),
                      child: _buildProductCard(context, product, isDark),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0000), Color(0xFF3D0000), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x66FF5252), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Category chip showing count
                  Obx(() {
                    final count = _getProducts().length;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$count items",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 18),
              // Search bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Obx(() => TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => _localSearch.value = v,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Search in $_categoryName...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFFFF5252), size: 22),
                    suffixIcon: _localSearch.value.isEmpty
                        ? null
                        : IconButton(
                      icon: const Icon(Icons.cancel_rounded,
                          color: Colors.grey, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _localSearch.value = "";
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Products product, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.1),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  getImageUrl(product.image),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 120,
                    color: isDark ? const Color(0xFF252525) : Colors.grey[100],
                    child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey, size: 32)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: Obx(() {
                  final wishlistCtrl = Get.find<WishlistController>();
                  final isLiked = wishlistCtrl.isWishlisted(product);
                  return GestureDetector(
                    onTap: () => wishlistCtrl.toggleWishlist(product),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? const Color(0xFFFF5252)
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: isLiked ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  );
                }),
              ),
              Positioned(
                bottom: 8, left: 10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "\$${product.price}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12),
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
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text("4.8",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500])),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.find<CartController>().addToCart(product),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFFF1744)]),
                          borderRadius: BorderRadius.circular(10),
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
                                    fontWeight: FontWeight.w700)),
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
}