import 'package:get/get.dart';
import 'package:py_app/app/data/models/product.model.dart';
import 'package:py_app/app/data/providers/api_provider.dart';
import 'package:py_app/app/services/storage_service.dart';

class HomeController extends GetxController {
  // 1. Reactive Variables
  Rxn<dynamic> currentUser = Rxn<dynamic>();
  final _apiProvider = Get.find<APIProvider>();
  var isLoading = false.obs;
  Rx<Product> products = Product().obs;

  // 🔴 2. ADD THIS MISSING VARIABLE (Fixes the error)
  var selectedTab = "All".obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentUserLogin();
    fechProduct();
  }

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
      isLoading.value = true; // Good practice to set loading true
      final response = await _apiProvider.getProducts();

      if (response.statusCode != 200) {
        Get.defaultDialog(
            title: "Error",
            middleText: "Failed to get product"
        );
        return; // Stop execution on error
      }

      products.value = Product.fromJson(response.data);
      // print("Product ${response.data}");

    } catch (e) {
      Get.defaultDialog(
          title: "Error",
          middleText: e.toString()
      );
    } finally {
      isLoading.value = false;
    }
  }
}