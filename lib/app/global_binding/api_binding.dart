import 'package:get/get.dart';

import '../data/providers/api_provider.dart';
import '../modules/cart/controllers/cart_controller.dart';
//can access all api
class APIBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(APIProvider(), permanent: true);
    // 2. Initialize Cart Controller so it's ready for any view
    Get.put(CartController(), permanent: true);
  }
}
