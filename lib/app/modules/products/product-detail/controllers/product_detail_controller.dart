import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  // ✅ carouselIndex lives in controller — tracked reactively by Obx
  var carouselIndex = 0.obs;

  // ✅ selectedSize lives in controller — not inside build()
  var selectedSize = 'M'.obs;

  /// Called once after first frame to pick a sensible default size
  void initSizes(List<String>? sizes) {
    if (sizes != null && sizes.isNotEmpty) {
      // Prefer 'M', otherwise fall back to first available size
      selectedSize.value =
      sizes.contains('M') ? 'M' : sizes.first;
    }
  }

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void updateCarouselIndex(int index) {
    carouselIndex.value = index;
  }
}