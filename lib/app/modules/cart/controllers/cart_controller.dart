import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;

import '../../../data/models/product.model.dart';
import '../../../data/providers/api_provider.dart';
import '../../profile/controllers/profile_controller.dart';

class CartItem {
  Products product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Products.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartData();
  }

  void saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartStringList = cartItems.map((item) => jsonEncode(item.toJson())).toList();
    prefs.setStringList('my_saved_cart', cartStringList);
  }

  void loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartStringList = prefs.getStringList('my_saved_cart');

    if (cartStringList != null) {
      var loadedItems = cartStringList.map((item) => CartItem.fromJson(jsonDecode(item))).toList();
      cartItems.assignAll(loadedItems);
    }
  }

  void addToCart(Products product) {
    int existingIndex = cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += 1;
    } else {
      cartItems.add(CartItem(product: product, quantity: 1));
    }

    cartItems.refresh();
    saveCartData();
  }

  void increaseQuantity(int index) {
    cartItems[index].quantity++;
    cartItems.refresh();
    saveCartData();
  }

  void decreaseQuantity(int index) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
      saveCartData();
    } else {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
    saveCartData();
  }

  double get totalPrice {
    double total = 0;
    for (var item in cartItems) {
      double itemPrice = double.tryParse(item.product.price.toString()) ?? 0.0;
      total += itemPrice * item.quantity;
    }
    return total;
  }

  // ==========================================
  // 🔴 FIXED: PASSING THE SHOPKEEPER ID TO LARAVEL
  // ==========================================
  Future<void> processPaymentSuccess() async {
    if (cartItems.isEmpty) return;

    isLoading.value = true;

    try {
      List<Map<String, dynamic>> orderItems = cartItems.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': double.tryParse(item.product.price.toString()) ?? 0.0,
      }).toList();

      // 🟢 DYNAMIC ID EXTRACTION
      // We get the ID from the first product in the cart.
      // We check both the direct field and the nested object.
      int? targetShopkeeperId;

      if (cartItems.isNotEmpty) {
        final product = cartItems.first.product;
        targetShopkeeperId = product.shopkeeperId ?? product.shopkeeper?.id;
      }

      // 🚨 STOP if the ID is missing to avoid the Server Error
      if (targetShopkeeperId == null) {
        Get.snackbar(
            "Order Error",
            "Product is not linked to a valid shop owner.",
            backgroundColor: Colors.orange,
            colorText: Colors.white
        );
        return;
      }

      final apiProvider = Get.find<APIProvider>();

      final response = await apiProvider.checkoutOrder(
        totalAmount: totalPrice,
        items: orderItems,
        shopkeeperId: targetShopkeeperId, // Pass the verified ID
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        cartItems.clear();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('my_saved_cart');

        if (Get.isBottomSheetOpen == true) Get.back();

        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchOrderStats();
        }

        Get.snackbar("Payment Successful 🎉", "Order sent to Admin Panel!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Checkout Failed", response.data['message'] ?? "Error");
      }

    } on dio.DioException catch (e) {
      Get.snackbar("Server Error", e.response?.data['message'] ?? "Connection Failed");
    } catch (e) {
      Get.snackbar("App Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}