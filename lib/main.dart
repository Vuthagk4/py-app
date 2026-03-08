import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:py_app/app/utils/helper/awesome_notifications_helper.dart';
import 'package:py_app/app/utils/helper/fcm_helper.dart';
import 'app/global_binding/api_binding.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/services/localization_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FcmHelper.initFcm();
  await AwesomeNotificationsHelper.init();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  await FirebaseMessaging.instance.subscribeToTopic('allDevices');
  await FirebaseMessaging.instance.subscribeToTopic('shopkeepers');
  await FirebaseMessaging.instance.subscribeToTopic('all_users');

  runApp(const MyApp());
}

// 🟢 Use a StatelessWidget to hold the Obx and GetMaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,

      // 🟢 LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFF5252),
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        fontFamily: LocalizationService.getFontFamily(),
        textTheme: TextTheme(
          bodyMedium: TextStyle(height: LocalizationService.getLineHeight(), color: Colors.black),
          bodyLarge: TextStyle(height: LocalizationService.getLineHeight(), color: Colors.black),
        ),
      ),

      // 🟢 DARK THEME — must be defined or Get.changeThemeMode() has nothing to switch to
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF5252),
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        fontFamily: LocalizationService.getFontFamily(),
        textTheme: TextTheme(
          bodyMedium: TextStyle(height: LocalizationService.getLineHeight(), color: Colors.white),
          bodyLarge: TextStyle(height: LocalizationService.getLineHeight(), color: Colors.white),
        ),
      ),

      // 🟢 Start with system default — ProfileController will override this on init
      themeMode: ThemeMode.system,

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: APIBinding(),
    );
  }
}