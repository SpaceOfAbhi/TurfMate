import 'package:dio/dio.dart';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/services/auth_services.dart';

final dio = Dio(BaseOptions(baseUrl: baseUrl));

void setupDio() {
  dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (
      options,
      handler,
    ) async {

      final token =
          await AuthService()
              .getToken();

      if (token != null) {

        options.headers[
          "Authorization"
        ] = "Bearer $token";
      }

      handler.next(options);
    },
  ),
);
}