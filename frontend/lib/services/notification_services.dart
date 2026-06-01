import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/core/network/dio_provider.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((message) async {
      await localNotifications.show(
        0,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android:  AndroidNotificationDetails(
            'match_channel',
            'Match Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });

    await localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> saveFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      print("SAVING TOKEN: $token");

      if (token == null) return;

      final response = await dio.post(
        "/notifications/fcm-token",
        data: {"token": token},
      );
      print("FCM SAVE RESPONSE:");
      print(response.data);
    } catch (e) {
      print("FCM SAVE ERROR: $e");
    }
  }
}
