import 'package:get/get.dart';
import 'package:py_app/app/data/models/product.model.dart';
import 'package:py_app/app/data/providers/api_provider.dart';
import 'package:py_app/app/routes/app_pages.dart';
import 'package:py_app/app/services/storage_service.dart';

import '../../product-detail/views/product_detail_view.dart';

class HomeController extends GetxController {
  // 1. Reactive Variables
  Rxn<dynamic> currentUser = Rxn<dynamic>();
  final _apiProvider = Get.find<APIProvider>();
  var isLoading = false.obs;
  Rx<Product> products = Product().obs;
  var searchQuery = "".obs;

  void searchProducts(String query) {
    searchQuery.value = query.toLowerCase();
  }
  void clearSearch() {
    searchQuery.value = "";
  }

  // 🔴 2. ADD THIS MISSING VARIABLE (Fixes the error)
  var selectedTab = "All".obs;
  var selectedCategoryId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUserLogin();
    fechProduct();
  }

  void changeCategory(int id) => selectedCategoryId.value = id;
  // 🔴 3. ADD THIS FUNCTION (To handle clicks)
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void getCurrentUserLogin() async {
    final user = await StorageService.read(key: 'user');
    currentUser.value = user;
    // print("User loaded: $user");
  }

  void fechProduct() async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.getProducts();

      if (response.statusCode != 200) {
        Get.defaultDialog(
            title: "Error",
            middleText: "Failed to get product");
        return;
      }

      // 🟢 response.data is already a Map — parse directly
      if (response.data is Map<String, dynamic>) {
        products.value = Product.fromJson(response.data);
      } else {
        print("Unexpected response format: ${response.data.runtimeType}");
      }

    } catch (e) {
      print("FETCH ERROR: $e"); // 🟢 print to terminal instead of dialog
      Get.defaultDialog(
          title: "Error",
          middleText: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  void goToDetail(Products product) {
    Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product); // 🟢 pass product as argument
  }
}