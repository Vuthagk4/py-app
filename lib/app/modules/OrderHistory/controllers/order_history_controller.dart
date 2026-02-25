import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';

class OrderHistoryController extends GetxController {
  final _provider = Get.find<APIProvider>();
  var orders = <dynamic>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final response = await _provider.getOrders();
      if (response.statusCode == 200) {
        orders.assignAll(response.data);
      }
    } catch (e) {
      print("Error fetching order history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}