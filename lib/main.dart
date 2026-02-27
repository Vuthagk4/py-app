import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/global_binding/api_binding.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFF5252),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF5252),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: APIBinding(),
    ),
  );
}
