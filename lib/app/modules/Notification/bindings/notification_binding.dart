import 'package:get/get.dart';

import '../../../data/providers/api_provider.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // 🟢 Ensure Provider is there before Controller asks for it
    Get.lazyPut(() => APIProvider());
    Get.lazyPut(() => NotificationController());
  }
}
