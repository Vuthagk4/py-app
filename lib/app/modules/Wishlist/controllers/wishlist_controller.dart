import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:py_app/app/data/models/product.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistController extends GetxController {
  final RxList<Products> wishlistItems = <Products>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  // Load from local storage
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('wishlist');
    if (data != null) {
      final List decoded = jsonDecode(data);
      wishlistItems.value = decoded.map((e) => Products.fromJson(e)).toList();
    }
  }

  // Save to local storage
  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(wishlistItems.map((p) => p.toJson()).toList());
    await prefs.setString('wishlist', encoded);
  }

  bool isWishlisted(Products product) {
    return wishlistItems.any((p) => p.id == product.id);
  }

  void toggleWishlist(Products product) {
    if (isWishlisted(product)) {
      wishlistItems.removeWhere((p) => p.id == product.id);
      Get.snackbar(
        "Removed",
        "${product.name} removed from wishlist",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } else {
      wishlistItems.add(product);
      Get.snackbar(
        "❤️ Added",
        "${product.name} added to wishlist",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF5252),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
    _saveWishlist();
  }

  int get count => wishlistItems.length;
}