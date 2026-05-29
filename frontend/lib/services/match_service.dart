import 'package:frontend/core/network/dio_provider.dart';
import 'package:frontend/models/match_model.dart';

class MatchService {
  Future<List<MatchModel>> getNearbyMatches({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final response = await dio.get(
      '/matches/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );

    final List data = response.data['matches'];

    return data.map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getMatchDetails(String matchId) async {
    final response = await dio.get('/matches/$matchId');

    return response.data['match'];
  }

  Future<void> joinMatch({required String matchId}) async {
    await dio.post('/matches/$matchId/join');
  }

  Future<bool> createMatch({
    required String sport,
    required String turfName,
    required int totalSlots,
    required double amountPerPerson,
  }) async {
    try {
      await dio.post(
        "/matches",

        data: {
          "sport": sport,
          "turfName": turfName,

          "latitude": 9.9312,
          "longitude": 76.2673,

          "startTime": DateTime.now().toIso8601String(),

          "endTime": DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),

          "totalSlots": totalSlots,

          "amountPerPerson": amountPerPerson,
        },
      );

      return true;
    } catch (e) {
      print(e);

      return false;
    }
  }
}
