import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';

class MyFeedbackController extends GetxController {
  final _provider = Get.find<APIProvider>();
  var feedbackList = <dynamic>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeedback();
  }

  void fetchFeedback() async {
    try {
      isLoading.value = true;
      final response = await _provider.getUserFeedback();
      if (response.statusCode == 200) {
        // Safely extract data from Laravel's response
        var data = response.data['data'];
        feedbackList.assignAll(data is List ? data : []);
      }
    } catch (e) {
      print("Feedback Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}