import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/dio_provider.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final response = await dio.post(
        '/auth/signup',

        data: {
          "name": name,
          "email": email,
          "password": password,
          "latitude": latitude,
          "longitude": longitude,
          "locationName": locationName,
        },
      );

      await _storage.write(key: "token", value: response.data["token"]);

      return true;
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login',

        data: {"email": email, "password": password},
      );

      await _storage.write(key: "token", value: response.data["token"]);
      return true;
    } catch (e) {
      print(e);

      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: "token");

    return token != null;
  }

  Future<void> logout() async {
    await _storage.delete(key: "token");
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }
}
