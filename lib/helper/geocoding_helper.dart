import 'package:geocoding/geocoding.dart';

/// Get city name from latitude and longitude
Future<String?> getCityFromPosition(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality; // City name
    }
  } catch (e) {
    print('⚠️ Failed to get city name: $e');
  }
  return null;
}