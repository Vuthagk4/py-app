import 'package:get/get.dart';
import '../controllers/home_controller.dart';
// 🟢 Import your ACTUAL UI Notification Controller
import 'package:py_app/app/modules/Notification/controllers/notification_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 🟢 Inject the UI controller so HomeView can find it
    Get.lazyPut<NotificationController>(() => NotificationController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}