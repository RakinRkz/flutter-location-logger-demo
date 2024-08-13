import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationHandler {
  var hasPermission = false;
  var userLocation='';
  var userCoordinates;
  var userCoordinates_string='';

  LocationHandler._privateConstructor();

  // Static instance of the class
  static final LocationHandler _instance =
      LocationHandler._privateConstructor();

  // Public getter to access the instance
  static LocationHandler get instance => _instance;

  Future<void> handleLocationPermission(BuildContext context) async {
    if (hasPermission == true) {
      print('location permission already ok');
      return;
    }
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      hasPermission = false;
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        hasPermission = false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      hasPermission = false;
    }
    hasPermission = true;
  }

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .then((Position position) {
      userCoordinates = position;
      userCoordinates_string = position.toString();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng() async {
    await placemarkFromCoordinates(
            userCoordinates!.latitude, userCoordinates!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      userLocation =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> updateLocation() async {
    if (!hasPermission) return;
    await _getCurrentPosition();
    await _getAddressFromLatLng();
  }
}
