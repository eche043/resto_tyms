import 'dart:async';

import 'package:location/location.dart';
import 'package:odrive_restaurant/common/config/api_call.dart';

class LocationMonitor {
  init() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await location.getLocation();
    location.enableBackgroundMode(enable: true);
    location.onLocationChanged.listen((LocationData currentLocation) {
      print(
          "Location ${currentLocation.latitude} ${currentLocation.longitude} ${currentLocation.speed} "
          "${DateTime.fromMillisecondsSinceEpoch(currentLocation.time!.toInt()).toString()}");
      if (prevCurrentLocationLatitude != currentLocation.latitude ||
          prevCurrentLocationLongitude != currentLocation.longitude) {
        print("Send");
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          prevCurrentLocationLatitude = currentLocation.latitude!;
          prevCurrentLocationLongitude = currentLocation.longitude!;
          sendLocation(
              currentLocation.latitude.toString(),
              currentLocation.longitude.toString(),
              currentLocation.speed.toString());
        }
      }
    });
  }

  double prevCurrentLocationLatitude = 0;
  double prevCurrentLocationLongitude = 0;

  bool _serviceEnabled = false;
  final Location location = Location();
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  // 1
  FutureOr<bool> checkPermissions() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    _permissionGranted = permissionGrantedResult;
    return (_permissionGranted == PermissionStatus.granted);
  }

  FutureOr<bool> requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      _permissionGranted = permissionRequestedResult;
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
}
