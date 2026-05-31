import 'package:dio/dio.dart';
import 'package:frontend/core/constants/constants.dart';

class TurfService {

  final dio = Dio(
    BaseOptions(
      baseUrl:
         baseUrl,
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