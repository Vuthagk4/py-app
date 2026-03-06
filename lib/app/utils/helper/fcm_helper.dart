import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'awesome_notifications_helper.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';

class FcmHelper {
  FcmHelper._();

  static late FirebaseMessaging messaging;

  static Future<void> initFcm() async {
    try {
      FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      analytics.logAppOpen();

      messaging = FirebaseMessaging.instance;

      await _generateFcmToken();
      await _setupFcmNotificationSettings();

      // Subscribe to all_users (Matches Laravel ProductObserver Topic)
      await FirebaseMessaging.instance.subscribeToTopic('all_users');

      FirebaseMessaging.onMessage.listen(_fcmForegroundHandler);
      FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    } catch (error) {
      Logger().e(error);
    }
  }

  static Future<void> _setupFcmNotificationSettings() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _generateFcmToken() async {
    try {
      var token = await messaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        sendFcmTokenToServer(token);
      } else {
        await Future.delayed(const Duration(seconds: 5));
        _generateFcmToken();
      }
    } catch (error) {
      Logger().e(error);
    }
  }

  static Future<void> sendFcmTokenToServer(String token) async {
    // 🟢 Call your APIProvider here to save token on CentOS 9 server
    // Example: await Get.find<APIProvider>().updateFcmToken(token);
  }

  @pragma('vm:entry-point')
  static Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
    _processAndShowNotification(message);
  }

  static Future<void> _fcmForegroundHandler(RemoteMessage message) async {
    _processAndShowNotification(message);
  }

  static void _processAndShowNotification(RemoteMessage message) {
    String? title = message.notification?.title ?? message.data['title'];
    String? body = message.notification?.body ?? message.data['body'];

    if (title == null && body == null) return;

    if (GetPlatform.isAndroid) {
      AwesomeNotificationsHelper.showNotification(
        // 🟢 Unique ID so multiple notifications can stay in the tray
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title ?? 'Store Update',
        body: body ?? 'Tap to view details',
        payload: message.data.cast<String, String>(),
        notificationLayout: message.data['image'] != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        largeIcon: message.data['image'],
      );
    }
  }

  static Future<void> _onMessageOpenApp(RemoteMessage message) async {
    // Deep linking logic handled in AwesomeNotificationsHelper or here
    if (message.data.containsKey('order_id')) {
      Get.toNamed('/order-history');
    }
  }

  // Helper for sending manual notifications (Room-based)
  static Future<void> sendNotification({
    required String deviceToken,
    required Map<String, dynamic> room,
    required String message,
    required bool isTextSend,
  }) async {
    try {
      const url = "https://us-central1-sala-it.cloudfunctions.net/app/send-notification";
      final data = {
        "deviceToken": deviceToken,
        "room": room,
        "userMessage": message,
        "messageType": isTextSend ? "text" : "image",
      };

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("Notification sent");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}