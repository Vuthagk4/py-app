import 'package:get/get.dart';

import '../controllers/order_success_view_controller.dart';

class OrderSuccessViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSuccessViewController>(
      () => OrderSuccessViewController(),
    );
  }
}
