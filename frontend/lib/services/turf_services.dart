import 'package:dio/dio.dart';

class TurfService {

  final dio = Dio(
    BaseOptions(
      baseUrl:
          "http://10.0.2.2:3000/api",
    ),
  );

  Future<List<dynamic>>
      getTurfs() async {

    final response =
        await dio.get(
      "/turfs",
    );

    return response
        .data["turfs"];
  }
}