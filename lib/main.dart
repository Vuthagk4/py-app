import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:py_app/app/utils/helper/awesome_notifications_helper.dart';
import 'package:py_app/app/utils/helper/fcm_helper.dart';
import 'app/global_binding/api_binding.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 🟢 1. Initialize Flutter & Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🟢 2. Initialize Notification Helpers
  await FcmHelper.initFcm();
  await AwesomeNotificationsHelper.init();

  // 🟢 3. Request Permission (Crucial for Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('User granted notification permission');
  }

  // 🟢 4. Subscribe to Topic
  // Ensure this matches the topic used in ProductController or CreateProduct.php
  await FirebaseMessaging.instance.subscribeToTopic('allDevices');
  await FirebaseMessaging.instance.subscribeToTopic('shopkeepers'); // 🟢 Add this
  await FirebaseMessaging.instance.subscribeToTopic('all_users');   // 🟢 Add this
  debugPrint('Subscribed to all_users topic');

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