import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/product.model.dart';
import '../../../data/providers/api_provider.dart';

class SearchProductController extends GetxController {
  final _provider = Get.find<APIProvider>();

  var products = <Products>[].obs;
  var isLoading = false.obs;
  RxBool isSearch = false.obs;

  void searchProduct({String? search, double? minPrice, double? maxPrice}) async {
    // 1. Reset state for new search
    isLoading.value = true;
    isSearch.value = true;

    try {
      // Ensure we send 'name' if that is what your APIProvider maps to
      final response = await _provider.searchProduct(
          search: search,
          maxPrice: maxPrice,
          minPrice: minPrice
      );

      if (response.statusCode == 200) {
        List<dynamic> rawData = [];

        // 2. Flexible data extraction
        if (response.data is Map && response.data.containsKey('data')) {
          rawData = response.data['data'];
        } else if (response.data is List) {
          rawData = response.data;
        }

        if (rawData.isNotEmpty) {
          // 3. Update observable list
          products.assignAll(
              rawData.map<Products>((json) => Products.fromJson(json)).toList()
          );
        } else {
          products.clear();
        }
      } else {
        Get.snackbar('Error', 'Server returned ${response.statusCode}');
      }
    } catch (e) {
      print("Search Error: $e");
      products.clear();
      Get.snackbar('Notice', "No results found or network issue");
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    products.clear();
    isSearch.value = false;
    isLoading.value = false;
  }
}