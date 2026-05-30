import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/core/network/dio_provider.dart';

class NotificationService {
  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();

    print("FCM TOKEN => $token");
  }

  Future<void> saveFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    await dio.post("/users/fcm-token", data: {"token": token});
  }
}
