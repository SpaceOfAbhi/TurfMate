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
    required String turf_id,
    required String turfName,
    required String startTime,
    required String endTime,
    required int totalSlots,
    required double amountPerPerson,
  }) async {
    try {
      await dio.post(
        "/matches",

        data: {
          "sport": sport,
          "turf_id": turf_id,
          "turfName": turfName,
          "startTime": startTime,
          "endTime": endTime,
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

  Future<List<dynamic>> getMyCreatedMatches() async {
    final response = await dio.get("/matches/my-created");

    return response.data["matches"];
  }

  Future<List<dynamic>> getMyJoinedMatches() async {
    final response = await dio.get("/matches/my-joined");

    return response.data["matches"];
  }

  Future<List<dynamic>> getMatchPlayers(String matchId) async {
    final response = await dio.get("/matches/$matchId/players");

    return response.data["players"];
  }

  Future<void> deleteMatch(String matchId) async {
    await dio.delete("/matches/$matchId");
  }

  Future<void> leaveMatch(String matchId) async {
    await dio.delete("/matches/$matchId/leave");
  }
}
