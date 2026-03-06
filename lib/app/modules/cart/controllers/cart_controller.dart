import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confetti/confetti.dart';
// 🟢 ONLY use this for LatLng to avoid conflicts
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/product.model.dart';
import '../../../data/providers/api_provider.dart';
import '../../Map_Shipping/MapPickerView.dart';
import '../../OrderSuccessView/views/order_success_view_view.dart';

class CartItem {
  Products product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Products.fromJson(json['product']),
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var selectedSlip = Rxn<XFile>();

  var pickedLocation = Rxn<LatLng>();
  var pickedAddressName = "".obs;

  final ImagePicker _picker = ImagePicker();
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
    loadCartData();
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }

  // --- 1. LOCAL STORAGE ---
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

  // --- 2. CART OPERATIONS ---
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

  double get totalCartPrice {
    return cartItems.fold(0.0, (sum, item) {
      double itemPrice = double.tryParse(item.product.price.toString()) ?? 0.0;
      return sum + (itemPrice * item.quantity);
    });
  }

  // --- 3. ACTIONS ---

  Future<void> openMapPicker() async {
    final dynamic result = await Get.to(() => const MapPickerView());

    // 🟢 Extract result safely
    if (result != null && result is Map) {
      pickedLocation.value = result['location'];
      pickedAddressName.value = result['address'];
      pickedLocation.refresh();
    }
  }

  Future<void> openBankingApp() async {
    final Uri url = Uri.parse("bakong://");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Notice", "Bakong app not installed.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  Future<void> capturePaymentSlip() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      selectedSlip.value = image;
    }
  }

  Future<void> pickPaymentSlip() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      selectedSlip.value = image;
    }
  }

  // --- 4. BACKEND UPLOAD ---
  Future<void> processPaymentSuccess() async {
    if (pickedLocation.value == null) {
      Get.snackbar("Location Missing", "Please select a delivery location on the map.");
      return;
    }
    if (selectedSlip.value == null || cartItems.isEmpty) return;

    isLoading.value = true;
    try {
      // 🟢 Prepare the file for upload
      String filePath = selectedSlip.value!.path;
      String fileName = selectedSlip.value!.name;

      dio.FormData formData = dio.FormData.fromMap({
        "total_amount": totalCartPrice,
        "address_id": 1, // Ensure this ID exists in your 'addresses' table
        "latitude": pickedLocation.value!.latitude,
        "delivery_address": pickedAddressName.value,
        "longitude": pickedLocation.value!.longitude,
        "shopkeeper_id": cartItems.first.product.shopkeeperId,
        // 🟢 The key 'image_qrcode' MUST match your Laravel $request->file('image_qrcode')
        "image_qrcode": await dio.MultipartFile.fromFile(filePath, filename: fileName),
        "items": jsonEncode(cartItems.map((e) => e.toJson()).toList()),
      });

      // 🟢 Call API with progress tracking
      final response = await Get.find<APIProvider>().uploadOrderWithSlip(
        formData,
        // Optional: Add progress tracking to your APIProvider method if needed
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        HapticFeedback.heavyImpact(); // 🟢 Physical feedback for success
        confettiController.play(); // 🟢 Celebration animation

        await Future.delayed(const Duration(seconds: 2));

        cartItems.clear();
        saveCartData();
        selectedSlip.value = null;
        Get.offAllNamed('/main'); // 🟢 Use offAllNamed to reset the stack
      }
    } on dio.DioException catch (e) {
      // 🟢 Catch specific Dio/Server errors
      String errorMsg = "Upload Failed";
      if (e.response?.statusCode == 413) errorMsg = "File too large for server";
      if (e.response?.statusCode == 422) errorMsg = "Invalid data format (Validation Error)";

      print("SERVER ERROR: ${e.response?.data}"); // Check your terminal for this!
      Get.snackbar("Error", errorMsg, backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("GENERAL ERROR: $e");
      Get.snackbar("Upload Failed", "Error connecting to server.");
    } finally {
      isLoading.value = false;
    }
  }
}