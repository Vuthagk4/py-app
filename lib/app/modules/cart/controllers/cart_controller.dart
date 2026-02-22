import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/product.model.dart';

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
      // Use assignAll so GetX keeps listening to the UI after a restart!
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

  Future<void> processPaymentSuccess() async {
    isLoading.value = true;

    // Simulate a brief network delay verifying the transaction
    await Future.delayed(const Duration(seconds: 1));

    // Clear cart and storage
    cartItems.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('my_saved_cart');

    isLoading.value = false;

    // Close the Bakong Bottom Sheet
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    // Show Success Message
    Get.snackbar(
      "Payment Successful 🎉",
      "Thank you! Your Bakong payment was received.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}