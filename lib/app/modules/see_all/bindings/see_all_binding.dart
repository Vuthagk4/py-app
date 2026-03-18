import 'package:get/get.dart';

import '../controllers/see_all_controller.dart';

class SeeAllBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeeAllController>(
      () => SeeAllController(),
    );
  }
}
