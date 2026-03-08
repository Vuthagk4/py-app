import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/localization_service.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Navigator(
          key: Get.nestedKey(1),
          initialRoute: Routes.HOME,
          onGenerateRoute: controller.onGenerateRoute,
        ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.onTab,
            type: BottomNavigationBarType.fixed,
            // 🟢 Apply dynamic font to selected labels
            selectedLabelStyle: TextStyle(
              fontFamily: LocalizationService.getFontFamily(),
              fontSize: 12,
            ),
            // 🟢 Apply dynamic font to unselected labels
            unselectedLabelStyle: TextStyle(
              fontFamily: LocalizationService.getFontFamily(),
              fontSize: 11,
            ),
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: "nav_home".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.search), label: "nav_search".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.shopping_bag_outlined), label: "nav_cart".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.person), label: "nav_profile".tr),
            ]),
      ),);
  }
}