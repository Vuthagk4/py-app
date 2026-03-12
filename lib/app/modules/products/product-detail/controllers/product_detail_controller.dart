import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  // ✅ FIX: carouselIndex lives HERE in the controller — not created
  //         inside build(). GetX can only track observables that exist
  //         before the widget tree is built.
  var carouselIndex = 0.obs;

  var selectedSize = 'M'.obs;

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void initSizes(List<String>? sizes) {
    if (sizes != null && sizes.isNotEmpty) {
      selectedSize.value =
      sizes.contains('M') ? 'M' : sizes.first;
    }
  }
}