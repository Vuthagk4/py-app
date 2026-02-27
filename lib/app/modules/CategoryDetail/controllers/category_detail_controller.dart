import 'package:get/get.dart';
import '../../../data/models/product.model.dart';

class CategoryDetailController extends GetxController {
  // Observable to handle potential list filtering in the future
  var productList = <Products>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Logic to handle category data if needed
  }

  // Example: Sort function you can call from the View
  void sortByPrice() {
    productList.sort((a, b) => a.price!.compareTo(b.price!));
  }
}