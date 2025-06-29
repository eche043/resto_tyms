import 'dart:math' show cos, sqrt, sin, atan2, pi;

import 'package:odrive_restaurant/common/const/const.dart';

class DistanceCalculatorWidget extends StatelessWidget {
  final double latitude1;
  final double longitude1;
  final double latitude2;
  final double longitude2;

  const DistanceCalculatorWidget({
    Key? key,
    required this.latitude1,
    required this.longitude1,
    required this.latitude2,
    required this.longitude2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double distance = calculateDistance(
      latitude1,
      longitude1,
      latitude2,
      longitude2,
    );

    print(distance);
    print("distance******************");

    return boldText(
        text: '${distance.toStringAsFixed(2)} km', color: appColor, size: 16.0);

    /* return Text(
      'Distance: ${distance.toStringAsFixed(2)} km',
      style: TextStyle(fontSize: 16),
    ); */
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0; // Earth radius in kilometers
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
