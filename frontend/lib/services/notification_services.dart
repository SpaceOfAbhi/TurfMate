import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/core/network/dio_provider.dart';

class NotificationService {
  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();

    print("FCM TOKEN => $token");
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
