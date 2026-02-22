import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/models/product.model.dart';
import '../../../data/providers/api_provider.dart';

class SearchProductController extends GetxController {
  final _provider = Get.find<APIProvider>();

  var products = <Products>[].obs;
  var isLoading = false.obs;
  RxBool isSearch = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void searchProduct({String? search, double? minPrice, double? maxPrice}) async {
    try {
      isLoading.value = true;
      final response = await _provider.searchProduct(
          search: search, maxPrice: maxPrice, minPrice: minPrice);

      if (response.statusCode == 200) {
        // 1. FIX: Handle the response data safely.
        // If your API wraps data in {"data": [...]}, we extract it here.
        List<dynamic> rawData = [];

        if (response.data is Map && response.data.containsKey('data')) {
          rawData = response.data['data']; // Extracts from {"success": true, "data": [...]}
        } else if (response.data is List) {
          rawData = response.data; // Uses directly if it's a flat array [...]
        }

        print("Data loaded: ${rawData.length} items");

        if (rawData.isNotEmpty) {
          // 2. FIX: Use .assignAll() and strictly type map<Products>
          products.assignAll(
              rawData.map<Products>((json) => Products.fromJson(json)).toList()
          );
        } else {
          // 3. FIX: Properly clear the RxList when no results are found
          products.clear();
        }
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } on DioException catch (e) {
      print(e);
      Get.snackbar('Network Error', e.message ?? 'Failed to connect to server');
    } catch (e) {
      // 4. FIX: Added a general catch block to catch JSON parsing errors
      print("Parsing Error: $e");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}