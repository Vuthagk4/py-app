import 'package:get/get.dart';
import '../controllers/my_feedback_view_controller.dart'; // Ensure path is correct

class MyFeedbackViewBinding extends Bindings {
  @override
  void dependencies() {
    // 🟢 Using lazyPut ensures the controller is only created when the view is opened
    Get.lazyPut<MyFeedbackController>(
          () => MyFeedbackController(),
    );
  }
}