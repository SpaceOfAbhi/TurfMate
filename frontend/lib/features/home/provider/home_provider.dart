import 'package:flutter_riverpod/flutter_riverpod.dart'
    show Provider, FutureProvider;
import 'package:frontend/models/match_model.dart';
import 'package:frontend/services/match_service.dart';
import 'package:geolocator/geolocator.dart';

final matchServiceProvider = Provider((ref) {
  return MatchService();
});

final nearbyMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final service = ref.read(matchServiceProvider);
  Position position = await Geolocator.getCurrentPosition();

  return service.getNearbyMatches(
    latitude: position.latitude,
    longitude: position.longitude,
    radius: 50,
  );
});
