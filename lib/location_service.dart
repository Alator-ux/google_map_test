import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps/constatns.dart';

class LocationService {
  static Future<LatLng> getLocation() async {
    var location = await Location().getLocation();
    var currentLatLng = LatLng(location.latitude ?? moscowCoords.latitude,
        location.longitude ?? moscowCoords.latitude);
    return currentLatLng;
  }
}
