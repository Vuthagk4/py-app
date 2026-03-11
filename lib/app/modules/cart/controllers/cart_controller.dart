import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confetti/confetti.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/product.model.dart';
import '../../../data/providers/api_provider.dart';
import '../../Map_Shipping/MapPickerView.dart';

class CartItem {
  Products product;
  int quantity;
  String? size;

  CartItem({required this.product, this.size, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Products.fromJson(json['product']),
    size: json['size'],
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'size': size,
  };
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var selectedSlip = Rxn<XFile>();

  var pickedLocation = Rxn<LatLng>();
  var pickedAddressName = "".obs;

  // ✅ Phone number entered by user in bottom sheet
  var customerPhone = "".obs;

  final ImagePicker _picker = ImagePicker();
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    loadCartData();
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }

  // ─── 1. LOCAL STORAGE ───────────────────────────────────────────────────
  void saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartStringList =
    cartItems.map((item) => jsonEncode(item.toJson())).toList();
    prefs.setStringList('my_saved_cart', cartStringList);
  }

  void loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartStringList = prefs.getStringList('my_saved_cart');
    if (cartStringList != null) {
      var loadedItems = cartStringList
          .map((item) => CartItem.fromJson(jsonDecode(item)))
          .toList();
      cartItems.assignAll(loadedItems);
    }
  }

  // ─── 2. CART OPERATIONS ─────────────────────────────────────────────────
  void addToCart(Products product, {String? size}) {
    int existingIndex = cartItems.indexWhere(
          (item) => item.product.id == product.id && item.size == size,
    );
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += 1;
    } else {
      cartItems.add(CartItem(product: product, quantity: 1, size: size));
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
      double itemPrice =
          double.tryParse(item.product.price.toString()) ?? 0.0;
      return sum + (itemPrice * item.quantity);
    });
  }

  // ─── 3. ACTIONS ─────────────────────────────────────────────────────────

  // ✅ Fixed: Get.back() was outside function before — now it's inside MapPickerView
  Future<void> openMapPicker() async {
    final dynamic result = await Get.to(() => const MapPickerView());
    if (result != null && result is Map) {
      pickedLocation.value = result['location'];

      // ✅ Use address name if available, otherwise fallback to coordinates
      pickedAddressName.value = result['address']?.toString().isNotEmpty == true
          ? result['address'].toString()
          : "Lat: ${(result['location'] as LatLng).latitude.toStringAsFixed(6)}, "
          "Lng: ${(result['location'] as LatLng).longitude.toStringAsFixed(6)}";

      pickedLocation.refresh();
      debugPrint("📍 Picked Address: ${pickedAddressName.value}");
    }
  }

  Future<void> openBankingApp() async {
    final Uri url = Uri.parse("bakong://");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Notice",
        "Bakong app not installed.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> capturePaymentSlip() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) selectedSlip.value = image;
  }

  Future<void> pickPaymentSlip() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) selectedSlip.value = image;
  }

  // ─── 4. BACKEND UPLOAD ──────────────────────────────────────────────────
  Future<void> processPaymentSuccess() async {
    // ✅ Validate location
    if (pickedLocation.value == null) {
      Get.snackbar(
        "Location Missing",
        "Please select a delivery location on the map.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ Validate phone
    if (customerPhone.value.trim().isEmpty) {
      Get.snackbar(
        "Phone Missing",
        "Please enter your phone number.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedSlip.value == null || cartItems.isEmpty) return;

    isLoading.value = true;
    try {
      String filePath = selectedSlip.value!.path;
      String fileName = selectedSlip.value!.name;

      // ✅ Never send empty delivery_address
      String deliveryAddress = pickedAddressName.value.isNotEmpty
          ? pickedAddressName.value
          : "Lat: ${pickedLocation.value!.latitude.toStringAsFixed(6)}, "
          "Lng: ${pickedLocation.value!.longitude.toStringAsFixed(6)}";

      dio.FormData formData = dio.FormData.fromMap({
        "total_amount":     totalCartPrice,
        "latitude":         pickedLocation.value!.latitude,
        "longitude":        pickedLocation.value!.longitude,
        "delivery_address": deliveryAddress,
        "phone":            customerPhone.value.trim(),
        "shopkeeper_id":    cartItems.first.product.shopkeeperId,
        "image_qrcode":     await dio.MultipartFile.fromFile(filePath, filename: fileName),
        "items":            jsonEncode(cartItems.map((e) => {
          'product': e.product.toJson(),
          'quantity': e.quantity,
          'size': e.size ?? '',
        }).toList()),
      });

      final response =
      await Get.find<APIProvider>().uploadOrderWithSlip(formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        HapticFeedback.heavyImpact();
        confettiController.play();
        await Future.delayed(const Duration(seconds: 2));

        // ✅ Reset everything after success
        cartItems.clear();
        saveCartData();
        selectedSlip.value = null;
        customerPhone.value = "";
        pickedLocation.value = null;
        pickedAddressName.value = "";

        Get.until((route) => route.settings.name == '/main');
      }
    } on dio.DioException catch (e) {
      String errorMsg = "Upload Failed";
      if (e.response?.statusCode == 413) errorMsg = "File too large for server";
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        errorMsg = errors?.toString() ?? "Validation Error";
      }
      if (e.response?.statusCode == 500) errorMsg = "Server Error";
      debugPrint("SERVER ERROR: ${e.response?.data}");
      Get.snackbar("Error", errorMsg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      debugPrint("GENERAL ERROR: $e");
      Get.snackbar("Upload Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}