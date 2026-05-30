import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/services/turf_services.dart';

final turfsProvider =
    FutureProvider<List<dynamic>>(
  (ref) async {

    return TurfService()
        .getTurfs();
  },
);