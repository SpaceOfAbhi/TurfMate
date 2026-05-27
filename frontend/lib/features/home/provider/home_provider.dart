import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider, FutureProvider;
import 'package:frontend/models/match_model.dart';
import 'package:frontend/services/match_service.dart';

final matchServiceProvider = Provider((ref) {
  return MatchService();
});

final nearbyMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {

  final service = ref.read(matchServiceProvider);

  return service.getNearbyMatches(
    latitude: 9.9312,
    longitude: 76.2673,
    radius: 10,
  );
});