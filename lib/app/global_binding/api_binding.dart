import 'package:get/get.dart';

import '../data/providers/api_provider.dart';
//can access all api
class APIBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(APIProvider(), permanent: true);
  }
}
