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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    _updatePolyline();
    //_setPolyline();

    location.onLocationChanged.listen((LocationData currentLocation) {
      print('changement-------------------');
      print(_currentLocation?.latitude);
      print(_currentLocation?.longitude);
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
    });
  }

  void changePosition(currentPosition) async {
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
    setState(() {
      allMarkers = allMarkers;
    });
  }

  Future<void> _getDirections(_origin, _destination, _waypoint) async {
    final String apiKey = 'AIzaSyDggn6Hwt1gbuAlfnvJ12OGr8Ygd2ufddQ';
    print(_origin.latitude);
    print(_origin.longitude);
    print(_origin.latitude);
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
    //List<LatLng> polylineCoordinates = [];
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

      _polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
  }

  // Méthode pour récupérer les points de la polyline entre les points spécifiés
  Future<List<LatLng>> _getPolylinePoints(
      LatLng origin, LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyDggn6Hwt1gbuAlfnvJ12OGr8Ygd2ufddQ", // Remplacez "YOUR_API_KEY" par votre clé d'API Google Maps
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving);

    List<LatLng> pointsList = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        pointsList.add(LatLng(point.latitude, point.longitude));
      });
    }
    return pointsList;
  }

  // Méthode pour mettre à jour la polyline en utilisant les points de la polyline obtenus
  Future<void> _updatePolyline() async {
    if (_currentLocation != null) {
      List<LatLng> points = [];
      points.add(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));
      if (!_shouldIncludeRestaurant()) {
        // Ajoute le restaurant comme point d'étape uniquement si nécessaire
        points
            .addAll(await _getPolylinePoints(points.last, _restaurantPosition));
      }
      points.addAll(await _getPolylinePoints(points.last, _clientPosition));

      setState(() {
        _polylinePoints = points;
      });
    }
  }

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // rayon de la terre en mètres

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
    setState(() {
      _restaurantPosition = LatLng(
          double.parse(widget.order.latRest),
          double.parse(widget.order.lngRest));
      _clientPosition = LatLng(double.parse(widget.order.lat),
          double.parse(widget.order.lng));
    });
    Location location = Location();
    try {
      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
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
    return distance > 100; // Changer 100 par la distance seuil en mètres
  }

  _markeradd() async {
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
        markerId: MarkerId("position restaurant"),
        position: _restaurantPosition,
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/images/House_icon.png", 130),
        ),
      ),
    );

    allMarkers.add(
      Marker(
        markerId: MarkerId("position client"),
        position: _clientPosition,
        infoWindow: InfoWindow(title: 'Client'),
        /* icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/test/delivery.png", 130),
        ), */
      ),
    );
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    String name =
        order.friend == 0 ? order.userName : order.friendName!;
    String phone = order.friend == 0 ? order.phone : order.friendPhone!;
    print("order------------");
    print(order);
    return Scaffold(
        body: Stack(
      children: [
        const BgContainer(),
        _currentLocation == null
            ? Center(child: CircularProgressIndicator())
            : GoogleMap(
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.terrain,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                },
                markers: Set.from(allMarkers),
                polylines: {
                  Polyline(
                    polylineId: PolylineId('route'),
                    color: Colors.blue,
                    width: 5,
                    //points: _polylinePoints
                    points: [
                      /* LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      if (_shouldIncludeRestaurant()) _restaurantPosition,
                      _clientPosition, */
                      ..._polylineCoordinates, // Ajoute les points de polylineCoordinates
                    ],
                  ),
                },
              ),
        const CustomAppBar(
          leadingImageAsset: drawer,
          title: 'Map',
          notificationImageAsset: notificationIcon,
          smsImageAsset: mailIcon,
        ),
        Positioned(
          bottom: 50.0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width * 0.9,
            height: 85.0,
            margin: const EdgeInsets.only(bottom: 50.0),
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: white,
                  backgroundImage: AssetImage(dpIcon),
                ),
                const SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    '$name'
                        .text
                        .size(14)
                        .fontWeight(FontWeight.w600)
                        .color(blackColor)
                        .make(),
                    Row(
                      children: [
                        const Icon(
                          Icons.call,
                          color: appColor,
                          size: 12,
                        ),
                        5.widthBox,
                        '$phone'
                            .text
                            .size(12)
                            .fontWeight(FontWeight.w600)
                            .color(fontGrey.withOpacity(0.7))
                            .make(),
                      ],
                    ),
                  ],
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
                              launchPhone(phone);
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
