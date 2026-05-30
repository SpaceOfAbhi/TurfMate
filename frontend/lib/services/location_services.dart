import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Map<String, dynamic>> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    final position = await Geolocator.getCurrentPosition();

    final places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = places.first;

    return {
      "latitude": position.latitude,

      "longitude": position.longitude,

      "locationName": "${place.locality}, ${place.administrativeArea}",
    };
  }
}
