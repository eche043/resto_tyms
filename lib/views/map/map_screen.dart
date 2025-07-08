// Remplacez le contenu de lib/views/map/map_screen.dart

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:odrive_restaurant/common/const/const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show asin, cos, sin, sqrt, atan2, pi;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:odrive_restaurant/model/order.dart';
import 'dart:convert';
import 'dart:async'; // ✅ Ajoutez cet import
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  Order order;
  MapScreen({super.key, required this.order});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  Location location = Location();
  LatLng _restaurantPosition = LatLng(7.3453, -5.1234);
  LatLng _clientPosition = LatLng(5.324, -4.214567);
  List<Marker> allMarkers = [];
  List<LatLng> _polylinePoints = [];
  List<LatLng> _polylineCoordinates = [];

  // ✅ Ajoutez cette variable pour gérer le StreamSubscription
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updatePolyline();

    // ✅ Modifiez cette partie pour stocker la subscription
    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      print('changement-------------------');
      print(currentLocation.latitude);
      print(currentLocation.longitude);

      // ✅ Vérifiez si le widget est encore monté avant d'appeler setState
      if (mounted) {
        allMarkers.removeWhere(
            (marker) => marker.markerId == const MarkerId("position livreur"));
        setState(() {
          _currentLocation = currentLocation;
          _controller?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            ),
          );
          changePosition(_currentLocation);
        });
      }
    });
  }

  // ✅ Ajoutez cette méthode dispose pour annuler la subscription
  @override
  void dispose() {
    // Annuler l'écoute des changements de localisation
    _locationSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void changePosition(currentPosition) async {
    // ✅ Vérifiez si le widget est encore monté
    if (!mounted) return;

    allMarkers.add(
      Marker(
        markerId: MarkerId("position livreur"),
        position: LatLng(
          _currentLocation!.latitude ?? 7.546855,
          _currentLocation!.longitude ?? -5.5471,
        ),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/images/delivery.png", 130),
        ),
      ),
    );

    // ✅ Vérifiez encore une fois avant setState
    if (mounted) {
      setState(() {
        allMarkers = allMarkers;
      });
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<List<LatLng>> _getPolylinePoints(LatLng start, LatLng end) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDggn6Hwt1gbuAlfnvJ12OGr8Ygd2ufddQ',
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void _updatePolyline() async {
    if (_currentLocation == null) return;

    List<LatLng> points = [];
    points
        .add(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));

    if (!_shouldIncludeRestaurant()) {
      points.addAll(await _getPolylinePoints(points.last, _restaurantPosition));
    }
    points.addAll(await _getPolylinePoints(points.last, _clientPosition));

    // ✅ Vérifiez si le widget est encore monté
    if (mounted) {
      setState(() {
        _polylinePoints = points;
      });
    }
  }

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _getCurrentLocation() async {
    // ✅ Vérifiez si le widget est encore monté
    if (!mounted) return;

    setState(() {
      _restaurantPosition = LatLng(double.parse(widget.order.latRest),
          double.parse(widget.order.lngRest));
      _clientPosition = LatLng(
          double.parse(widget.order.lat), double.parse(widget.order.lng));
    });

    Location location = Location();
    try {
      LocationData locationData = await location.getLocation();

      // ✅ Vérifiez si le widget est encore monté
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
        });
      }

      print("Latitude: ${_currentLocation!.latitude}");
      print("Longitude: ${_currentLocation!.longitude}");
      _markeradd();
    } catch (e) {
      print("Error getting location: $e");
    }
    _getDirections(_currentLocation, _clientPosition, _restaurantPosition);
  }

  bool _shouldIncludeRestaurant() {
    if (_currentLocation == null) return true;
    double distance = distanceBetween(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      _restaurantPosition.latitude,
      _restaurantPosition.longitude,
    );
    return distance > 100;
  }

  _markeradd() async {
    // ✅ Vérifiez si le widget est encore monté
    if (!mounted) return;

    allMarkers.add(
      Marker(
        markerId: MarkerId("position livreur"),
        position: LatLng(
          _currentLocation!.latitude ?? 7.546855,
          _currentLocation!.longitude ?? -5.5471,
        ),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/images/delivery.png", 130),
        ),
      ),
    );

    allMarkers.add(
      Marker(
        markerId: MarkerId("Restaurant"),
        position: _restaurantPosition,
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/images/restaurant.png", 130),
        ),
      ),
    );

    allMarkers.add(
      Marker(
        markerId: MarkerId("Client"),
        position: _clientPosition,
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/images/destination.png", 130),
        ),
      ),
    );

    // ✅ Vérifiez si le widget est encore monté
    if (mounted) {
      setState(() {
        allMarkers = allMarkers;
      });
    }
  }

  Future<void> _getDirections(_origin, _destination, _waypoint) async {
    final String apiKey = 'AIzaSyDggn6Hwt1gbuAlfnvJ12OGr8Ygd2ufddQ';
    print(_origin.latitude);
    print(_origin.longitude);
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&waypoints=${_waypoint.latitude},${_waypoint.longitude}&key=$apiKey';

    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final routes = json['routes'] as List;
      print(routes);
      if (routes.isNotEmpty) {
        final points = routes[0]['overview_polyline']['points'];
        print(
            "points-----------------------------------------*****************");
        print(points);
        _decodePolyline(points);
      }
    }
  }

  void _decodePolyline(String encoded) {
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      _polylineCoordinates.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    // ✅ Vérifiez si le widget est encore monté
    if (mounted) {
      setState(() {
        _polylineCoordinates = _polylineCoordinates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? phone = widget.order.friend == 0
        ? widget.order.phone
        : widget.order.friendPhone;
    final order = widget.order;

    return Scaffold(
        body: Stack(
      children: [
        if (_currentLocation != null)
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: Set<Marker>.from(allMarkers),
            polylines: Set<Polyline>.from([
              Polyline(
                polylineId: PolylineId('route'),
                color: appColor,
                width: 5,
                points: _polylineCoordinates,
              ),
            ]),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  _currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: 15.0,
            ),
          )
        else
          Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Commande #${order.id}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Client: ${order.friend == 0 ? order.userName : order.friendName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Total: ${order.total} F',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: appColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: appColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              Get.to(
                                  () => ChatScreen(
                                        orderId: order.id,
                                        currentUserId:
                                            prefs.getInt("userId") ?? 0,
                                        receiverId: order.user,
                                      ),
                                  transition: Transition.downToUp,
                                  duration: const Duration(milliseconds: 500));
                            },
                            child: const Center(
                                child: Icon(
                              Icons.mail,
                              color: white,
                              size: 32,
                            )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(4),
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: appColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (phone != null && phone.isNotEmpty) {
                                launchPhone(phone);
                              }
                            },
                            child: Center(
                                child: Icon(
                              Icons.call,
                              color: white,
                              size: 32,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
