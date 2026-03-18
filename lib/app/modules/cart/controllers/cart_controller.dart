import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confetti/confetti.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as pathLib;

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
    if (image != null) {
      final permanent = await _copyToPermanent(image);
      selectedSlip.value = permanent;
    }
  }

  Future<void> pickPaymentSlip() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      final permanent = await _copyToPermanent(image);
      selectedSlip.value = permanent;
    }
  }
  Future<XFile> _copyToPermanent(XFile image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'slip_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final permanentPath = '${appDir.path}/$fileName';
    await File(image.path).copy(permanentPath);
    debugPrint("✅ Slip saved permanently: $permanentPath");
    return XFile(permanentPath);
  }

  // ─── 4. BACKEND UPLOAD ──────────────────────────────────────────────────
  Future<void> processPaymentSuccess() async {
    // ✅ Validate location
    if (pickedLocation.value == null) {
      Get.snackbar("Location Missing", "Please select a delivery location.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // ✅ Validate phone
    if (customerPhone.value.trim().isEmpty) {
      Get.snackbar("Phone Missing", "Please enter your phone number.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // ✅ Validate slip
    if (selectedSlip.value == null) {
      Get.snackbar("Slip Missing", "Please attach your payment slip.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (cartItems.isEmpty) return;

    isLoading.value = true;
    try {
      final String filePath = selectedSlip.value!.path;

      // ✅ Double-check file actually exists before sending
      final uploadFile = File(filePath);
      if (!await uploadFile.exists()) {
        // File was lost — re-copy from picker won't work, ask user to re-select
        selectedSlip.value = null;
        Get.snackbar(
          "Slip Error",
          "Slip image was lost. Please select again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final String fileName = 'slip_${DateTime.now().millisecondsSinceEpoch}.jpg';

      String deliveryAddress = pickedAddressName.value.isNotEmpty
          ? pickedAddressName.value
          : "Lat: ${pickedLocation.value!.latitude.toStringAsFixed(6)}, "
          "Lng: ${pickedLocation.value!.longitude.toStringAsFixed(6)}";

      // ✅ Debug logs — check these in Android Studio Logcat
      debugPrint("📤 File path: $filePath");
      debugPrint("📦 File exists: ${await uploadFile.exists()}");
      debugPrint("📦 File size: ${await uploadFile.length()} bytes");
      debugPrint("🏪 ShopkeeperId: ${cartItems.first.product.shopkeeperId}");
      debugPrint("📞 Phone: ${customerPhone.value}");
      debugPrint("📍 Address: $deliveryAddress");
      debugPrint("🛒 Items count: ${cartItems.length}");

      dio.FormData formData = dio.FormData.fromMap({
        "total_amount":     totalCartPrice.toStringAsFixed(2),
        "latitude":         pickedLocation.value!.latitude,
        "longitude":        pickedLocation.value!.longitude,
        "delivery_address": deliveryAddress,
        "phone":            customerPhone.value.trim(),
        "shopkeeper_id":    cartItems.first.product.shopkeeperId,
        "image_qrcode":     await dio.MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: dio.DioMediaType('image', 'jpeg'),
        ),
        "items": jsonEncode(cartItems.map((e) => {
          'product': e.product.toJson(),
          'quantity': e.quantity,
          'size': e.size ?? '',
        }).toList()),
      });

      final response = await Get.find<APIProvider>().uploadOrderWithSlip(formData);

      debugPrint("✅ Response status: ${response.statusCode}");
      debugPrint("✅ Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Delete permanent file after success to free storage
        await uploadFile.delete();

        HapticFeedback.heavyImpact();
        confettiController.play();
        await Future.delayed(const Duration(seconds: 2));

        cartItems.clear();
        saveCartData();
        selectedSlip.value = null;
        customerPhone.value = "";
        pickedLocation.value = null;
        pickedAddressName.value = "";

        Get.until((route) => route.settings.name == '/main');

      } else {
        // ✅ Handle non-exception HTTP errors (e.g. 422, 500 without throw)
        debugPrint("❌ Non-success status: ${response.statusCode}");
        debugPrint("❌ Response body: ${response.data}");
        Get.snackbar(
          "Failed",
          response.data?['message'] ?? "Order failed. Try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }

    } on dio.DioException catch (e) {
      debugPrint("❌ DioException: ${e.type}");
      debugPrint("❌ Status: ${e.response?.statusCode}");
      debugPrint("❌ Data: ${e.response?.data}");
      debugPrint("❌ Message: ${e.message}");

      String errorMsg = "Upload Failed";
      if (e.response?.statusCode == 401) errorMsg = "Session expired. Please login again.";
      if (e.response?.statusCode == 413) errorMsg = "Image too large. Please use a smaller image.";
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        final message = e.response?.data['message'];
        errorMsg = errors?.toString() ?? message ?? "Validation Error";
      }
      if (e.response?.statusCode == 500) {
        errorMsg = e.response?.data['message'] ?? "Server Error";
      }
      if (e.type == dio.DioExceptionType.connectionTimeout) errorMsg = "Connection timed out.";
      if (e.type == dio.DioExceptionType.receiveTimeout)    errorMsg = "Server took too long to respond.";

      Get.snackbar("Error", errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5));

    } catch (e) {
      debugPrint("❌ General error: $e");
      Get.snackbar("Upload Failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}