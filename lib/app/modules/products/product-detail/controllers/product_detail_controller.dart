import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  var selectedSize = 'M'.obs;
  final count = 0.obs;
  void selectSize(String size) {
    selectedSize.value = size;
  }
  void initSizes(List<String>? sizes) {
    if (sizes != null && sizes.isNotEmpty) {
      selectedSize.value = sizes.contains('M') ? 'M' : sizes.first;
    }
  }
}
