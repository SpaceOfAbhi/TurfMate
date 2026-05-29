import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/match_service.dart';

final myCreatedMatchesProvider =
    FutureProvider((ref) async {

  return MatchService()
      .getMyCreatedMatches();
});

final myJoinedMatchesProvider =
    FutureProvider((ref) async {

  return MatchService()
      .getMyJoinedMatches();
});