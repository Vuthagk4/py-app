import 'package:get/get.dart';
import 'package:py_app/app/data/models/product.model.dart';
import 'package:py_app/app/data/providers/api_provider.dart';
import 'package:py_app/app/routes/app_pages.dart';
import 'package:py_app/app/services/storage_service.dart';

class HomeController extends GetxController {
  // ── Reactive Variables ────────────────────────────────────────────────────
  Rxn<dynamic> currentUser = Rxn<dynamic>();
  final _apiProvider = Get.find<APIProvider>();
  var isLoading = false.obs;
  Rx<Product> products = Product().obs;
  var searchQuery = "".obs;
  var selectedTab = "All".obs;
  var selectedCategoryId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUserLogin();
    fechProduct();
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void searchProducts(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void clearSearch() {
    searchQuery.value = "";
  }

  // ── Category ──────────────────────────────────────────────────────────────
  void changeCategory(int id) => selectedCategoryId.value = id;

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  void getCurrentUserLogin() async {
    final user = await StorageService.read(key: 'user');
    currentUser.value = user;
  }

  // ── Fetch Products ────────────────────────────────────────────────────────
  // ✅ forceRefresh: false = skip if data already loaded (faster re-opens)
  // ✅ forceRefresh: true  = always reload (used on pull-to-refresh)
  void fechProduct({bool forceRefresh = false}) async {
    // ✅ If data already loaded and not forced, skip the API call
    if (!forceRefresh && products.value.categories != null) return;

    try {
      isLoading.value = true;
      final response = await _apiProvider.getProducts();

      if (response.statusCode != 200) {
        Get.defaultDialog(
            title: "Error", middleText: "Failed to get product");
        return;
      }

      if (response.data is Map<String, dynamic>) {
        products.value = Product.fromJson(response.data);
      } else {
        print(
            "Unexpected response format: ${response.data.runtimeType}");
      }
    } catch (e) {
      print("FETCH ERROR: $e");
      Get.defaultDialog(title: "Error", middleText: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void goToDetail(Products product) {
    Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product);
  }
}